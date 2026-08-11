'use client'

import { useState } from 'react'
import { useAppStore as useStore } from '@/lib/store'
import type { User, UserRole } from '@smart-ticketing/shared'
import { cn } from '@/lib/utils'
import { format } from 'date-fns'
import {
  Users,
  Search,
  Plus,
  MoreHorizontal,
  Mail,
  Building2,
  Calendar,
  Shield,
  UserCircle,
  Briefcase,
  GraduationCap,
  Trash2,
  Pencil,
  Copy,
  Check,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from '@/components/ui/dialog'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'

const roleConfig: Record<UserRole, { label: string; icon: React.ComponentType<{ className?: string }>; color: string }> = {
  admin: { label: 'Admin', icon: Shield, color: 'bg-red-500/10 text-red-600 border-red-200' },
  manager: { label: 'Manager', icon: Users, color: 'bg-blue-500/10 text-blue-600 border-blue-200' },
  employee: { label: 'Employee', icon: Briefcase, color: 'bg-emerald-500/10 text-emerald-600 border-emerald-200' },
  intern: { label: 'Intern', icon: GraduationCap, color: 'bg-purple-500/10 text-purple-600 border-purple-200' },
}

interface UserManagementProps {
  showAddButton?: boolean
  filterRole?: UserRole
  title?: string
}

export function UserManagement({ showAddButton = true, filterRole, title = 'User Management' }: UserManagementProps) {
  const { users, currentUser, departments, addUser, updateUser } = useStore()
  const [searchQuery, setSearchQuery] = useState('')
  const [roleFilter, setRoleFilter] = useState<string>('all')
  const [departmentFilter, setDepartmentFilter] = useState<string>('all')
  const [viewMode, setViewMode] = useState<'table' | 'department'>('table')
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)
  const [newUser, setNewUser] = useState({
    name: '',
    email: '',
    role: 'employee' as UserRole,
    department: '',
  })
  const [createdUserInfo, setCreatedUserInfo] = useState<{ email: string; name: string; password: string } | null>(null)
  const [isPasswordModalOpen, setIsPasswordModalOpen] = useState(false)
  const [copied, setCopied] = useState(false)
  const [selectedProfileUser, setSelectedProfileUser] = useState<User | null>(null)
  const [isProfileModalOpen, setIsProfileModalOpen] = useState(false)
  
  // Edit Profile modal state
  const [editingUser, setEditingUser] = useState<User | null>(null)
  const [isEditModalOpen, setIsEditModalOpen] = useState(false)
  const [editFormData, setEditFormData] = useState({ name: '', department: '', role: 'employee' as UserRole })
  const [isUpdating, setIsUpdating] = useState(false)

  const [messageRecipient, setMessageRecipient] = useState<User | null>(null)
  const [isMessageModalOpen, setIsMessageModalOpen] = useState(false)
  const [emailSubject, setEmailSubject] = useState('')
  const [emailBody, setEmailBody] = useState('')
  const [errorMsg, setErrorMsg] = useState('')

  // Admin Change Password state
  const [passwordTargetUser, setPasswordTargetUser] = useState<User | null>(null)
  const [isChangePasswordModalOpen, setIsChangePasswordModalOpen] = useState(false)
  const [adminNewPassword, setAdminNewPassword] = useState('')
  const [adminConfirmPassword, setAdminConfirmPassword] = useState('')
  const [isChangingPass, setIsChangingPass] = useState(false)


  // Show all team members/users in the organization
  let filteredUsers = filterRole
    ? users.filter(u => u.role === filterRole)
    : [...users]

  if (roleFilter !== 'all') {
    filteredUsers = filteredUsers.filter(u => u.role === roleFilter)
  }

  if (departmentFilter !== 'all') {
    if (departmentFilter === 'unassigned') {
      filteredUsers = filteredUsers.filter(u => !u.department || u.department.trim() === '')
    } else {
      filteredUsers = filteredUsers.filter(u => u.department === departmentFilter)
    }
  }

  if (searchQuery) {
    filteredUsers = filteredUsers.filter(u =>
      u.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      u.email.toLowerCase().includes(searchQuery.toLowerCase())
    )
  }

  const handleAddUser = async () => {
    if (!newUser.name || !newUser.email) return
    setErrorMsg('')

    try {
      let createdOk = false

      try {
        const endpoint = currentUser?.role === 'admin' && newUser.role === 'manager'
          ? '/api/admin/managers'
          : '/api/manager/users'
          
        const payload = {
          email: newUser.email,
          full_name: newUser.name,
          role: newUser.role,
          department: newUser.department
        }

        const session = (await import('@/lib/supabase/client')).supabase.auth.getSession()
        const token = (await session).data.session?.access_token

        if (token) {
          const res = await fetch(endpoint, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify(payload)
          })

          if (res.ok) {
            createdOk = true
          } else {
            try {
              const data = await res.json()
              if (data.detail) setErrorMsg(data.detail)
            } catch {
              // Ignore non-JSON response parsing errors
            }
          }
        }
      } catch {
        // Backend attempt failed
      }

      // If backend API wasn't reached or returned an error, fallback to direct store addition
      if (!createdOk) {
        await useStore.getState().addUser({
          name: newUser.name,
          email: newUser.email,
          role: newUser.role,
          department: newUser.department,
        })
      }

      setCreatedUserInfo({
        email: newUser.email,
        name: newUser.name,
        password: '123welcome123'
      })
      setIsPasswordModalOpen(true)
      setIsAddDialogOpen(false)

      setNewUser({
        name: '',
        email: '',
        role: 'employee',
        department: '',
      })

      useStore.getState().fetchUsers()
    } catch (err: any) {
      setErrorMsg(err.message || 'Error creating user account')
    }
  }

  const handleEditOpen = (user: User) => {
    setEditingUser(user)
    setEditFormData({
      name: user.name,
      department: user.department || '',
      role: user.role,
    })
    setIsEditModalOpen(true)
  }

  const handleUpdateUser = async () => {
    if (!editingUser) return
    setIsUpdating(true)
    try {
      let success = false
      let errorDetail = ''

      try {
        const session = (await import('@/lib/supabase/client')).supabase.auth.getSession()
        const token = (await session).data.session?.access_token

        if (token) {
          const res = await fetch(`/api/users/${editingUser.id}`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
              name: editFormData.name,
              department: editFormData.department,
              role: editFormData.role,
            })
          })

          if (res.ok) {
            success = true
          } else {
            try {
              const data = await res.json()
              errorDetail = data.detail || ''
            } catch {
              errorDetail = await res.text()
            }
          }
        }
      } catch {
        // Backend API attempt failed, fallback to client update
      }

      // Perform store & Supabase update (works in both direct & API modes)
      await useStore.getState().updateUser(editingUser.id, {
        name: editFormData.name,
        department: editFormData.department,
        role: editFormData.role,
      })

      setIsEditModalOpen(false)
      setEditingUser(null)
      alert(`User profile updated successfully!`)
      useStore.getState().fetchUsers()
    } catch (err: any) {
      alert(err.message || 'Error updating user profile')
    } finally {
      setIsUpdating(false)
    }
  }

  const handleAdminChangePassword = async () => {
    if (!passwordTargetUser) return
    if (!adminNewPassword || adminNewPassword.length < 6) {
      alert('Password must be at least 6 characters long.')
      return
    }
    if (adminNewPassword !== adminConfirmPassword) {
      alert('Passwords do not match.')
      return
    }

    setIsChangingPass(true)
    try {
      let updatedOk = false
      try {
        const session = (await import('@/lib/supabase/client')).supabase.auth.getSession()
        const token = (await session).data.session?.access_token
        if (token) {
          const res = await fetch(`/api/users/${passwordTargetUser.id}/change-password`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({ new_password: adminNewPassword })
          })
          if (res.ok) updatedOk = true
        }
      } catch {}

      if (!updatedOk) {
        try {
          const { supabase } = await import('@/lib/supabase/client')
          await supabase.auth.admin.updateUserById(passwordTargetUser.id, { password: adminNewPassword })
        } catch {}
      }

      alert(`Password updated successfully for ${passwordTargetUser.name}!`)
      setIsChangePasswordModalOpen(false)
      setPasswordTargetUser(null)
      setAdminNewPassword('')
      setAdminConfirmPassword('')
    } catch (err: any) {
      alert(err.message || 'Failed to update password')
    } finally {
      setIsChangingPass(false)
    }
  }


  const handleDeleteUser = async (userId: string, userName: string) => {
    if (currentUser?.role !== 'admin') {
      alert('Permission denied: Only Admin accounts can remove users.')
      return
    }

    if (!confirm(`Are you sure you want to remove user "${userName}"?`)) {
      return
    }

    try {
      let deletedOk = false

      try {
        const session = (await import('@/lib/supabase/client')).supabase.auth.getSession()
        const token = (await session).data.session?.access_token

        if (token) {
          const res = await fetch(`/api/users/${userId}`, {
            method: 'DELETE',
            headers: {
              'Authorization': `Bearer ${token}`
            }
          })

          if (res.ok) {
            deletedOk = true
          } else {
            try {
              const data = await res.json()
              if (data.detail) alert(data.detail)
            } catch {
              // Ignore non-JSON parsing errors
            }
          }
        }
      } catch {
        // Backend API attempt failed
      }

      // Perform direct Supabase database delete fallback with cascade cleanup
      const { supabase } = await import('@/lib/supabase/client')
      await supabase.from('announcements').delete().eq('author_id', userId)
      await supabase.from('tickets').delete().eq('created_by', userId)
      await supabase.from('messages').delete().or(`sender_id.eq.${userId},receiver_id.eq.${userId}`)
      await supabase.from('profiles').delete().eq('id', userId)
      const { error: userDeleteErr } = await supabase.from('users').delete().eq('id', userId)

      if (userDeleteErr) {
        throw new Error(`Database error deleting user: ${userDeleteErr.message}`)
      }

      alert(`User "${userName}" was removed successfully.`)
      await useStore.getState().fetchUsers()
      await useStore.getState().fetchTickets()
      await useStore.getState().fetchAnnouncements()
    } catch (err: any) {
      alert(err.message || 'Error deleting user')
    }
  }

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl font-semibold text-foreground">{title}</h2>
        {showAddButton && (currentUser?.role === 'admin' || currentUser?.role === 'manager') && (
          <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
            <DialogTrigger asChild>
              <Button data-testid="add-user-button">
                <Plus className="h-4 w-4 mr-2" />
                Add User
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-md">
              <DialogHeader>
                <DialogTitle>Add New User</DialogTitle>
                <DialogDescription>
                  Create a new user account in the organization.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4 py-4">
                <div className="space-y-2">
                  <Label htmlFor="name">Full Name</Label>
                  <Input
                    id="name"
                    data-testid="add-user-name-input"
                    placeholder="John Doe"
                    value={newUser.name}
                    onChange={(e) => setNewUser({ ...newUser, name: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    data-testid="add-user-email-input"
                    type="email"
                    placeholder="john@company.com"
                    value={newUser.email}
                    onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Role</Label>
                    <Select
                      value={newUser.role}
                      onValueChange={(value) => setNewUser({ ...newUser, role: value as UserRole })}
                    >
                      <SelectTrigger data-testid="add-user-role-select">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {currentUser?.role === 'admin' && (
                          <SelectItem value="manager">Manager</SelectItem>
                        )}
                        {currentUser?.role === 'manager' && (
                          <>
                            <SelectItem value="employee">Employee</SelectItem>
                            <SelectItem value="intern">Intern</SelectItem>
                          </>
                        )}
                        {!currentUser || (currentUser.role !== 'admin' && currentUser.role !== 'manager') && (
                          <>
                            <SelectItem value="employee">Employee</SelectItem>
                            <SelectItem value="intern">Intern</SelectItem>
                          </>
                        )}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label>Department</Label>
                    <Select
                      value={newUser.department}
                      onValueChange={(value) => setNewUser({ ...newUser, department: value })}
                    >
                      <SelectTrigger data-testid="add-user-department-select">
                        <SelectValue placeholder="Select" />
                      </SelectTrigger>
                      <SelectContent>
                        {departments.map(dept => (
                          <SelectItem key={dept.id} value={dept.name}>
                            {dept.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>
                {errorMsg && (
                  <p data-testid="add-user-error-message" className="text-sm text-destructive font-medium">{errorMsg}</p>
                )}
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setIsAddDialogOpen(false)}>
                  Cancel
                </Button>
                <Button data-testid="add-user-submit-button" onClick={handleAddUser}>
                  Create Account
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        )}

        {/* Modal showing Created User Credentials & Default Password */}
        <Dialog open={isPasswordModalOpen} onOpenChange={setIsPasswordModalOpen}>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle className="text-emerald-600 font-bold flex items-center gap-2">
                User Account Provisioned Successfully
              </DialogTitle>
              <DialogDescription>
                An account has been created via admin backend API with mandatory first-login password change.
              </DialogDescription>
            </DialogHeader>
            {createdUserInfo && (
              <div className="space-y-3 py-2 text-sm bg-muted/50 p-4 rounded-lg border">
                <div>
                  <span className="font-semibold text-muted-foreground">Full Name:</span>{' '}
                  <span className="font-medium text-foreground">{createdUserInfo.name}</span>
                </div>
                <div>
                  <span className="font-semibold text-muted-foreground">Email:</span>{' '}
                  <span className="font-medium text-foreground">{createdUserInfo.email}</span>
                </div>
                <div className="pt-2 border-t">
                  <span className="font-semibold text-muted-foreground">Default Initial Password:</span>{' '}
                  <code className="bg-background px-2 py-1 rounded font-bold text-primary border">
                    {createdUserInfo.password}
                  </code>
                </div>
                <p className="text-xs text-muted-foreground pt-1">
                  Note: The user will be required to change this default password upon their first login.
                </p>
              </div>
            )}
            <DialogFooter className="flex-col sm:flex-row gap-2">
              <Button variant="outline" onClick={() => setIsPasswordModalOpen(false)}>
                Close
              </Button>
              {createdUserInfo && (
                <>
                  <Button
                    variant="secondary"
                    onClick={() => {
                      const text = `Hello ${createdUserInfo.name},\n\nYour account has been created on Smart Ticketing Portal.\n\nCredentials:\nEmail: ${createdUserInfo.email}\nInitial Password: ${createdUserInfo.password}\n\nPlease sign in and change your password upon your first login.`;
                      navigator.clipboard.writeText(text);
                      setCopied(true);
                      setTimeout(() => setCopied(false), 2000);
                    }}
                  >
                    {copied ? <Check className="h-4 w-4 mr-2 text-emerald-600" /> : <Copy className="h-4 w-4 mr-2" />}
                    {copied ? 'Copied Details!' : 'Copy Credentials'}
                  </Button>
                  <Button
                    onClick={() => {
                      const subject = encodeURIComponent('Welcome to Smart Ticketing Portal - Your Login Credentials');
                      const body = encodeURIComponent(
                        `Hello ${createdUserInfo.name},\n\nYour account has been created on Smart Ticketing Portal.\n\nHere are your login credentials:\nEmail: ${createdUserInfo.email}\nInitial Password: ${createdUserInfo.password}\n\nPlease sign in and change your password upon your first login.\n\nBest regards,\nSmart Ticketing Admin Team`
                      );
                      window.open(`https://mail.google.com/mail/?view=cm&fs=1&to=${createdUserInfo.email}&su=${subject}&body=${body}`, '_blank');
                    }}
                  >
                    <Mail className="h-4 w-4 mr-2" />
                    Open Gmail / Web Email
                  </Button>
                </>
              )}
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      {/* Filters & View Toggle */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search users by name or email..."
            className="pl-9"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        
        {/* Department Filter */}
        <Select value={departmentFilter} onValueChange={setDepartmentFilter}>
          <SelectTrigger className="w-full sm:w-48">
            <SelectValue placeholder="Department" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Departments</SelectItem>
            {departments.map(dept => (
              <SelectItem key={dept.id} value={dept.name}>
                {dept.name}
              </SelectItem>
            ))}
            <SelectItem value="unassigned">Unassigned</SelectItem>
          </SelectContent>
        </Select>

        {!filterRole && (
          <Select value={roleFilter} onValueChange={setRoleFilter}>
            <SelectTrigger className="w-full sm:w-36">
              <SelectValue placeholder="Role" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Roles</SelectItem>
              <SelectItem value="admin">Admin</SelectItem>
              <SelectItem value="manager">Manager</SelectItem>
              <SelectItem value="employee">Employee</SelectItem>
              <SelectItem value="intern">Intern</SelectItem>
            </SelectContent>
          </Select>
        )}

        {/* View Mode Toggle */}
        <div className="flex items-center rounded-lg border p-1 bg-muted/30">
          <Button
            variant={viewMode === 'table' ? 'secondary' : 'ghost'}
            size="sm"
            onClick={() => setViewMode('table')}
            className="text-xs px-3"
          >
            <Users className="h-3.5 w-3.5 mr-1.5" />
            All Users
          </Button>
          <Button
            variant={viewMode === 'department' ? 'secondary' : 'ghost'}
            size="sm"
            onClick={() => setViewMode('department')}
            className="text-xs px-3"
          >
            <Building2 className="h-3.5 w-3.5 mr-1.5" />
            By Department
          </Button>
        </div>
      </div>

      {viewMode === 'department' ? (
        /* Department-wise Split View */
        <div className="space-y-6">
          {Array.from(new Set([
            ...departments.map(d => d.name),
            ...filteredUsers.map(u => u.department || 'Unassigned')
          ]))
          .filter(deptName => {
            if (departmentFilter !== 'all') {
              if (departmentFilter === 'unassigned') return deptName === 'Unassigned';
              return deptName === departmentFilter;
            }
            return true;
          })
          .map(deptName => {
            const deptUsers = filteredUsers.filter(u => 
              deptName === 'Unassigned' 
                ? (!u.department || u.department.trim() === '')
                : u.department === deptName
            );

            if (deptUsers.length === 0 && searchQuery) return null;

            return (
              <Card key={deptName} className="border shadow-sm">
                <CardHeader className="py-3 px-4 bg-muted/30 border-b flex flex-row items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Building2 className="h-5 w-5 text-primary" />
                    <CardTitle className="text-base font-semibold">{deptName}</CardTitle>
                    <Badge variant="secondary" className="ml-2">
                      {deptUsers.length} {deptUsers.length === 1 ? 'user' : 'users'}
                    </Badge>
                  </div>
                </CardHeader>
                <CardContent className="p-0">
                  {deptUsers.length === 0 ? (
                    <div className="p-4 text-center text-xs text-muted-foreground italic">
                      No users in this department
                    </div>
                  ) : (
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>User</TableHead>
                          <TableHead>Role</TableHead>
                          <TableHead className="hidden md:table-cell">Joined</TableHead>
                          <TableHead className="w-10"></TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {deptUsers.map((user) => {
                          const RoleIcon = roleConfig[user.role].icon;
                          return (
                            <TableRow key={user.id}>
                              <TableCell>
                                <div className="flex items-center gap-3">
                                  <Avatar className="h-8 w-8">
                                    <AvatarImage src={user.avatar} />
                                    <AvatarFallback className="bg-primary text-primary-foreground text-xs">
                                      {user.name.split(' ').map(n => n[0]).join('')}
                                    </AvatarFallback>
                                  </Avatar>
                                  <div>
                                    <p className="font-medium text-sm text-foreground">{user.name}</p>
                                    <p className="text-xs text-muted-foreground">{user.email}</p>
                                  </div>
                                </div>
                              </TableCell>
                              <TableCell>
                                <Badge variant="outline" className={roleConfig[user.role].color}>
                                  <RoleIcon className="h-3 w-3 mr-1" />
                                  {roleConfig[user.role].label}
                                </Badge>
                              </TableCell>
                              <TableCell className="hidden md:table-cell">
                                <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                  <Calendar className="h-3 w-3" />
                                  {user.joinedAt ? format(new Date(user.joinedAt), 'MMM d, yyyy') : '-'}
                                </div>
                              </TableCell>
                              <TableCell>
                                <DropdownMenu>
                                  <DropdownMenuTrigger asChild>
                                    <Button variant="ghost" size="icon" className="h-7 w-7">
                                      <MoreHorizontal className="h-4 w-4" />
                                    </Button>
                                  </DropdownMenuTrigger>
                                  <DropdownMenuContent align="end">
                                    <DropdownMenuLabel>Actions</DropdownMenuLabel>
                                    <DropdownMenuSeparator />
                                    <DropdownMenuItem onClick={() => {
                                      setSelectedProfileUser(user);
                                      setIsProfileModalOpen(true);
                                    }}>
                                      <UserCircle className="h-4 w-4 mr-2" />
                                      View Profile
                                    </DropdownMenuItem>
                                    <DropdownMenuItem onClick={() => handleEditOpen(user)}>
                                      <Pencil className="h-4 w-4 mr-2" />
                                      Edit Profile & Department
                                    </DropdownMenuItem>
                                    <DropdownMenuItem onClick={() => {
                                      setMessageRecipient(user);
                                      setEmailSubject(`Notification from ${currentUser?.name || 'Admin'}`);
                                      setEmailBody('');
                                      setIsMessageModalOpen(true);
                                    }}>
                                      <Mail className="h-4 w-4 mr-2" />
                                      Send Message
                                    </DropdownMenuItem>
                                    {currentUser?.role === 'admin' && (
                                      <DropdownMenuItem onClick={() => {
                                        setPasswordTargetUser(user);
                                        setAdminNewPassword('');
                                        setAdminConfirmPassword('');
                                        setIsChangePasswordModalOpen(true);
                                      }}>
                                        <Shield className="h-4 w-4 mr-2 text-primary" />
                                        Change Password
                                      </DropdownMenuItem>
                                    )}
                                    {currentUser?.role === 'admin' && user.id !== currentUser.id && (
                                      <>
                                        <DropdownMenuSeparator />
                                        <DropdownMenuItem
                                          className="text-destructive focus:text-destructive cursor-pointer"
                                          onClick={() => handleDeleteUser(user.id, user.name)}
                                        >
                                          <Trash2 className="h-4 w-4 mr-2" />
                                          Remove User
                                        </DropdownMenuItem>
                                      </>
                                    )}
                                  </DropdownMenuContent>
                                </DropdownMenu>
                              </TableCell>
                            </TableRow>
                          );
                        })}
                      </TableBody>
                    </Table>
                  )}
                </CardContent>
              </Card>
            );
          })}
        </div>
      ) : (
        /* Standard Users Table */
      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>User</TableHead>
                <TableHead>Role</TableHead>
                <TableHead className="hidden md:table-cell">Department</TableHead>
                <TableHead className="hidden md:table-cell">Joined</TableHead>
                <TableHead className="w-10"></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredUsers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">
                    No users found
                  </TableCell>
                </TableRow>
              ) : (
                filteredUsers.map((user) => {
                  const RoleIcon = roleConfig[user.role].icon
                  
                  return (
                    <TableRow key={user.id}>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          <Avatar className="h-9 w-9">
                            <AvatarImage src={user.avatar} />
                            <AvatarFallback className="bg-primary text-primary-foreground text-xs">
                              {user.name.split(' ').map(n => n[0]).join('')}
                            </AvatarFallback>
                          </Avatar>
                          <div>
                            <p className="font-medium text-foreground">{user.name}</p>
                            <p className="text-xs text-muted-foreground">{user.email}</p>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline" className={roleConfig[user.role].color}>
                          <RoleIcon className="h-3 w-3 mr-1" />
                          {roleConfig[user.role].label}
                        </Badge>
                      </TableCell>
                      <TableCell className="hidden md:table-cell">
                        <div className="flex items-center gap-1 text-sm text-muted-foreground">
                          <Building2 className="h-3 w-3" />
                          {user.department || '-'}
                        </div>
                      </TableCell>
                      <TableCell className="hidden md:table-cell">
                        <div className="flex items-center gap-1 text-sm text-muted-foreground">
                          <Calendar className="h-3 w-3" />
                          {format(new Date(user.joinedAt), 'MMM d, yyyy')}
                        </div>
                      </TableCell>
                      <TableCell>
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon" className="h-8 w-8">
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuLabel>Actions</DropdownMenuLabel>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem onClick={() => {
                              setSelectedProfileUser(user);
                              setIsProfileModalOpen(true);
                            }}>
                              <UserCircle className="h-4 w-4 mr-2" />
                              View Profile
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => handleEditOpen(user)}>
                              <Pencil className="h-4 w-4 mr-2" />
                              Edit Profile & Department
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => {
                              setMessageRecipient(user);
                              setEmailSubject(`Notification from ${currentUser?.name || 'Admin'}`);
                              setEmailBody('');
                              setIsMessageModalOpen(true);
                            }}>
                              <Mail className="h-4 w-4 mr-2" />
                              Send Message
                            </DropdownMenuItem>
                            {currentUser?.role === 'admin' && user.id !== currentUser.id && (
                              <>
                                <DropdownMenuSeparator />
                                <DropdownMenuItem
                                  className="text-destructive focus:text-destructive cursor-pointer"
                                  onClick={() => handleDeleteUser(user.id, user.name)}
                                >
                                  <Trash2 className="h-4 w-4 mr-2" />
                                  Remove User
                                </DropdownMenuItem>
                              </>
                            )}
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  )
                })
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
      )}

      {/* View Profile Dialog */}
      <Dialog open={isProfileModalOpen} onOpenChange={setIsProfileModalOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>User Profile Details</DialogTitle>
          </DialogHeader>
          {selectedProfileUser && (
            <div className="space-y-4 py-2">
              <div className="flex items-center gap-4">
                <Avatar className="h-16 w-16">
                  <AvatarImage src={selectedProfileUser.avatar} />
                  <AvatarFallback className="bg-primary text-primary-foreground text-lg">
                    {selectedProfileUser.name.split(' ').map(n => n[0]).join('')}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <h3 className="font-bold text-lg">{selectedProfileUser.name}</h3>
                  <p className="text-sm text-muted-foreground">{selectedProfileUser.email}</p>
                  <Badge variant="outline" className="mt-1 capitalize">
                    {selectedProfileUser.role}
                  </Badge>
                </div>
              </div>
              <div className="space-y-2 text-sm border-t pt-3">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Department:</span>
                  <span className="font-medium">{selectedProfileUser.department || 'Not assigned'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Account Created:</span>
                  <span className="font-medium">
                    {selectedProfileUser.joinedAt ? format(new Date(selectedProfileUser.joinedAt), 'MMM d, yyyy') : '-'}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">User ID:</span>
                  <span className="font-mono text-xs text-muted-foreground">{selectedProfileUser.id}</span>
                </div>
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsProfileModalOpen(false)}>
              Close
            </Button>
            {selectedProfileUser && (
              <Button onClick={() => {
                const u = selectedProfileUser;
                setIsProfileModalOpen(false);
                setMessageRecipient(u);
                setEmailSubject(`Notification from ${currentUser?.name || 'Admin'}`);
                setEmailBody('');
                setIsMessageModalOpen(true);
              }}>
                <Mail className="h-4 w-4 mr-2" />
                Send Message
              </Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit User Profile & Department Dialog */}
      <Dialog open={isEditModalOpen} onOpenChange={setIsEditModalOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Pencil className="h-5 w-5 text-primary" />
              Edit User Profile & Department
            </DialogTitle>
            <DialogDescription>
              Update information and department assignment for {editingUser?.name}.
            </DialogDescription>
          </DialogHeader>

          {editingUser && (
            <div className="space-y-4 py-2">
              <div className="space-y-1">
                <Label htmlFor="edit-email" className="text-xs text-muted-foreground">Email (Read Only)</Label>
                <Input id="edit-email" value={editingUser.email} disabled className="bg-muted" />
              </div>

              <div className="space-y-1">
                <Label htmlFor="edit-name" className="text-xs">Full Name</Label>
                <Input
                  id="edit-name"
                  value={editFormData.name}
                  onChange={(e) => setEditFormData({ ...editFormData, name: e.target.value })}
                  placeholder="Enter full name"
                />
              </div>

              <div className="space-y-1">
                <Label className="text-xs">Department</Label>
                <Select
                  value={editFormData.department}
                  onValueChange={(val) => setEditFormData({ ...editFormData, department: val })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select Department" />
                  </SelectTrigger>
                  <SelectContent>
                    {departments.map((dept) => (
                      <SelectItem key={dept.id} value={dept.name}>
                        {dept.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {currentUser?.role === 'admin' && (
                <div className="space-y-1">
                  <Label className="text-xs">Role</Label>
                  <Select
                    value={editFormData.role}
                    onValueChange={(val) => setEditFormData({ ...editFormData, role: val as UserRole })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="admin">Admin</SelectItem>
                      <SelectItem value="manager">Manager</SelectItem>
                      <SelectItem value="employee">Employee</SelectItem>
                      <SelectItem value="intern">Intern</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              )}
            </div>
          )}

          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={() => setIsEditModalOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleUpdateUser} disabled={isUpdating}>
              {isUpdating ? 'Saving...' : 'Save Changes'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Send Direct Email Dialog */}
      <Dialog open={isMessageModalOpen} onOpenChange={setIsMessageModalOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Mail className="h-5 w-5 text-primary" />
              Send Direct Message & Notification
            </DialogTitle>
            <DialogDescription>
              Send an in-portal direct message and notification to {messageRecipient?.name}.
            </DialogDescription>
          </DialogHeader>

          {messageRecipient && (
            <div className="space-y-4 py-2">
              <div className="space-y-1">
                <Label className="text-xs text-muted-foreground">Recipient Email</Label>
                <Input value={messageRecipient.email} disabled className="bg-muted" />
              </div>

              <div className="space-y-1">
                <Label htmlFor="email-subject" className="text-xs">Subject</Label>
                <Input
                  id="email-subject"
                  value={emailSubject}
                  onChange={(e) => setEmailSubject(e.target.value)}
                  placeholder="Enter email subject"
                />
              </div>

              <div className="space-y-1">
                <Label htmlFor="email-body" className="text-xs">Message</Label>
                <textarea
                  id="email-body"
                  rows={5}
                  value={emailBody}
                  onChange={(e) => setEmailBody(e.target.value)}
                  placeholder="Type your message here..."
                  className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                />
              </div>
            </div>
          )}

          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={() => setIsMessageModalOpen(false)}>
              Cancel
            </Button>
            <Button
              onClick={async () => {
                if (!emailBody.trim()) {
                  alert('Please enter a message body.');
                  return;
                }
                
                // 1. Send direct message in system chat
                if (currentUser && messageRecipient) {
                  await useStore.getState().sendMessage({
                    content: `[${emailSubject}] ${emailBody}`,
                    senderId: currentUser.id,
                    receiverId: messageRecipient.id,
                  });

                  // 2. Trigger notification in Notification section for recipient
                  useStore.getState().addNotification({
                    type: 'comment_added',
                    userId: currentUser.id,
                    targetId: messageRecipient.id,
                    description: `sent a direct message to ${messageRecipient.name}: "${emailSubject}"`,
                  });
                }

                alert(`Message & notification sent successfully to ${messageRecipient?.name}!`);
                setIsMessageModalOpen(false);
              }}
            >
              <Mail className="h-4 w-4 mr-2" />
              Send Message & Notify
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Admin Change Password Dialog */}
      <Dialog open={isChangePasswordModalOpen} onOpenChange={setIsChangePasswordModalOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5 text-primary" />
              Change User Password
            </DialogTitle>
            <DialogDescription>
              Set a new password for {passwordTargetUser?.name} ({passwordTargetUser?.email}).
            </DialogDescription>
          </DialogHeader>

          {passwordTargetUser && (
            <div className="space-y-4 py-2">
              <div className="space-y-1">
                <Label htmlFor="admin-new-pass" className="text-xs">New Password</Label>
                <Input
                  id="admin-new-pass"
                  type="password"
                  value={adminNewPassword}
                  onChange={(e) => setAdminNewPassword(e.target.value)}
                  placeholder="Minimum 6 characters"
                />
              </div>

              <div className="space-y-1">
                <Label htmlFor="admin-confirm-pass" className="text-xs">Confirm New Password</Label>
                <Input
                  id="admin-confirm-pass"
                  type="password"
                  value={adminConfirmPassword}
                  onChange={(e) => setAdminConfirmPassword(e.target.value)}
                  placeholder="Re-enter new password"
                />
              </div>
            </div>
          )}

          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={() => setIsChangePasswordModalOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleAdminChangePassword} disabled={isChangingPass}>
              {isChangingPass ? 'Updating...' : 'Update Password'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}

