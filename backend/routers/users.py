from fastapi import APIRouter, HTTPException, Header, Depends, status
from database import supabase, supabase_admin
from schemas import UserCreate, UserUpdate, UserResponse, ManagerCreateRequest, UserCreateRequest
from typing import List, Optional

router = APIRouter(tags=["Users & Provisioning"])

DEFAULT_PASSWORD = "123welcome123"

def get_current_user_profile(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid Authorization header"
        )
    token = authorization.split(" ")[1]
    try:
        user_res = supabase.auth.get_user(token)
        if not user_res or not user_res.user:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
        user_id = user_res.user.id
        profile_res = supabase_admin.from_("profiles").select("*").eq("id", user_id).execute()
        if not profile_res.data:
            # Fallback if profile row was named users
            profile_res = supabase_admin.from_("users").select("*").eq("id", user_id).execute()
        if not profile_res.data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User profile not found")
        return profile_res.data[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=f"Authentication failed: {str(e)}")

def require_role(required_role: str):
    def role_checker(profile: dict = Depends(get_current_user_profile)):
        if profile.get("role") != required_role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Permission denied: Requires {required_role} role"
            )
        return profile
    return role_checker

@router.post("/admin/managers", status_code=status.HTTP_201_CREATED)
def create_manager(payload: ManagerCreateRequest, current_user: dict = Depends(get_current_user_profile)):
    try:
        # Create user in Supabase Auth via Admin API
        auth_res = supabase_admin.auth.admin.create_user({
            "email": payload.email,
            "password": DEFAULT_PASSWORD,
            "email_confirm": True,
            "user_metadata": {
                "full_name": payload.full_name,
                "role": "manager"
            }
        })
        new_user_id = auth_res.user.id

        profile_data = {
            "id": new_user_id,
            "email": payload.email,
            "full_name": payload.full_name,
            "role": "manager",
            "created_by": current_user["id"],
            "must_change_password": True,
            "department": payload.department
        }
        
        # Upsert profile record
        supabase_admin.from_("profiles").upsert(profile_data).execute()

        # Insert/upsert into legacy users table so frontend store queries find this user
        legacy_user_data = {
            "id": new_user_id,
            "name": payload.full_name,
            "email": payload.email,
            "role": "manager",
            "department": payload.department
        }
        try:
            supabase_admin.from_("users").upsert(legacy_user_data).execute()
        except Exception:
            pass
        
        return {
            "message": "Manager account created successfully",
            "user": profile_data
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create manager account: {str(e)}"
        )

@router.post("/manager/users", status_code=status.HTTP_201_CREATED)
def create_team_user(payload: UserCreateRequest, current_user: dict = Depends(get_current_user_profile)):
    try:
        auth_res = supabase_admin.auth.admin.create_user({
            "email": payload.email,
            "password": DEFAULT_PASSWORD,
            "email_confirm": True,
            "user_metadata": {
                "full_name": payload.full_name,
                "role": payload.role
            }
        })
        new_user_id = auth_res.user.id

        profile_data = {
            "id": new_user_id,
            "email": payload.email,
            "full_name": payload.full_name,
            "role": payload.role,
            "created_by": current_user["id"],
            "must_change_password": True,
            "department": payload.department
        }

        supabase_admin.from_("profiles").upsert(profile_data).execute()

        legacy_user_data = {
            "id": new_user_id,
            "name": payload.full_name,
            "email": payload.email,
            "role": payload.role,
            "department": payload.department
        }
        try:
            supabase_admin.from_("users").upsert(legacy_user_data).execute()
        except Exception:
            pass

        return {
            "message": f"{payload.role.capitalize()} account created successfully",
            "user": profile_data
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create user account: {str(e)}"
        )

@router.get("/users/", response_model=List[UserResponse])
def get_users():
    try:
        response = supabase.from_("users").select("*").execute()
        return response.data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch users: {str(e)}"
        )

@router.put("/users/{user_id}", status_code=status.HTTP_200_OK)
def update_user_profile(user_id: str, payload: UserUpdate, current_user: dict = Depends(get_current_user_profile)):
    # Admins can update any user; Managers can update employees, interns, or their own department users
    user_role = current_user.get("role")
    if user_role not in ["admin", "manager"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Permission denied: Only Admin or Manager can edit user profile"
        )
        
    try:
        update_data = {}
        if payload.name is not None:
            update_data["full_name"] = payload.name
        if payload.role is not None and user_role == "admin":
            update_data["role"] = payload.role
        if payload.department is not None:
            update_data["department"] = payload.department

        if update_data:
            supabase_admin.from_("profiles").update(update_data).eq("id", user_id).execute()
            
            # Synchronize legacy users table
            legacy_update = {}
            if payload.name is not None:
                legacy_update["name"] = payload.name
            if payload.role is not None and user_role == "admin":
                legacy_update["role"] = payload.role
            if payload.department is not None:
                legacy_update["department"] = payload.department
            if legacy_update:
                supabase_admin.from_("users").update(legacy_update).eq("id", user_id).execute()

        return {"message": "User updated successfully", "user_id": user_id}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update user: {str(e)}"
        )

@router.delete("/users/{user_id}", status_code=status.HTTP_200_OK)
def delete_user(user_id: str, current_user: dict = Depends(get_current_user_profile)):
    if current_user.get("role") != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Permission denied: Only Admin accounts can remove users"
        )
    try:
        # Delete from Supabase Auth via Admin API
        try:
            supabase_admin.auth.admin.delete_user(user_id)
        except Exception:
            pass

        # Cleanup dependent references in tickets, announcements, and messages to avoid FK constraint errors
        try:
            supabase_admin.from_("announcements").delete().eq("author_id", user_id).execute()
        except Exception:
            pass

        try:
            supabase_admin.from_("tickets").delete().eq("created_by", user_id).execute()
        except Exception:
            pass

        try:
            supabase_admin.from_("messages").delete().or_(f"sender_id.eq.{user_id},receiver_id.eq.{user_id}").execute()
        except Exception:
            pass

        # Delete from profiles and users tables
        supabase_admin.from_("profiles").delete().eq("id", user_id).execute()
        supabase_admin.from_("users").delete().eq("id", user_id).execute()

        return {"message": "User deleted successfully", "user_id": user_id}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete user: {str(e)}"
        )

@router.put("/users/{user_id}/change-password", status_code=status.HTTP_200_OK)
def change_user_password(user_id: str, payload: dict, current_user: dict = Depends(get_current_user_profile)):
    new_password = payload.get("new_password") or payload.get("password")
    if not new_password or len(new_password) < 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password must be at least 6 characters long"
        )
    
    # Permission check: Admin can change any user's password. Non-admin can only change their own password.
    requester_role = current_user.get("role")
    requester_id = current_user.get("id")
    if requester_role != "admin" and requester_id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Permission denied: Only Admin accounts can change another user's password"
        )

    try:
        # Update password in Supabase Auth via Admin API
        supabase_admin.auth.admin.update_user_by_id(user_id, {"password": new_password})
        
        # Reset must_change_password flag if set
        try:
            supabase_admin.from_("profiles").update({"must_change_password": False}).eq("id", user_id).execute()
        except Exception:
            pass

        return {"message": "Password updated successfully", "user_id": user_id}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update password: {str(e)}"
        )


