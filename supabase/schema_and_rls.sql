-- 1. Create / Update profiles table with required columns
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT NOT NULL DEFAULT 'employee' CHECK (role IN ('admin', 'manager', 'employee', 'intern')),
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    must_change_password BOOLEAN NOT NULL DEFAULT TRUE,
    department TEXT,
    avatar TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Ensure profiles columns exist if profiles table already was created
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'employee' CHECK (role IN ('admin', 'manager', 'employee', 'intern'));
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS department TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar TEXT;

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Helper function to get current user role safely
CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS TEXT AS $$
  SELECT role FROM public.profiles WHERE id = user_id;
$$ LANGUAGE sql SECURITY DEFINER;

-- 2. Drop legacy policies on profiles if any exist
DROP POLICY IF EXISTS "Admin full access profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admin full access all" ON public.profiles;
DROP POLICY IF EXISTS "Manager profiles policy" ON public.profiles;
DROP POLICY IF EXISTS "Manager insert employees" ON public.profiles;
DROP POLICY IF EXISTS "Self profile policy" ON public.profiles;
DROP POLICY IF EXISTS "Self update profile policy" ON public.profiles;
DROP POLICY IF EXISTS "Deny anon all" ON public.profiles;

-- 3. RLS Policies
-- Admin: full access (select/insert/update/delete)
CREATE POLICY "Admin full access all" ON public.profiles
FOR ALL TO authenticated
USING (public.get_user_role(auth.uid()) = 'admin')
WITH CHECK (public.get_user_role(auth.uid()) = 'admin');

-- Manager: view own profile & created profiles
CREATE POLICY "Manager profiles policy" ON public.profiles
FOR SELECT TO authenticated
USING (
    public.get_user_role(auth.uid()) = 'manager' AND (id = auth.uid() OR created_by = auth.uid())
);

-- Manager: insert only employee/intern rows they create
CREATE POLICY "Manager insert employees" ON public.profiles
FOR INSERT TO authenticated
WITH CHECK (
  public.get_user_role(auth.uid()) = 'manager'
  AND role IN ('employee','intern')
  AND created_by = auth.uid()
);

-- Employee / Intern: view only their own profile row
CREATE POLICY "Self profile policy" ON public.profiles
FOR SELECT TO authenticated
USING (
    id = auth.uid()
);

-- User Self Update: users can update their profile (e.g., must_change_password)
CREATE POLICY "Self update profile policy" ON public.profiles
FOR UPDATE TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Explicit anon deny (documentation + safety net)
CREATE POLICY "Deny anon all" ON public.profiles
FOR ALL TO anon
USING (false) WITH CHECK (false);

-- 4. Role Escalation Prevention Trigger
CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.role IS DISTINCT FROM OLD.role OR NEW.created_by IS DISTINCT FROM OLD.created_by)
     AND auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'Not allowed to change role or created_by directly';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_prevent_role_escalation ON public.profiles;

CREATE TRIGGER trg_prevent_role_escalation
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.prevent_role_escalation();
