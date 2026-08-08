'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAppStore as useStore } from '@/lib/store'
import { DashboardLayout } from '@/components/layout/dashboard-layout'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Separator } from '@/components/ui/separator'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  User,
  Mail,
  Building2,
  Calendar,
  Shield,
  Ticket,
  CheckCircle,
  Clock,
  Camera,
  KeyRound,
} from 'lucide-react'
import { format } from 'date-fns'

const DEPARTMENTS = [
  'Engineering',
  'Management',
  'Design',
  'Marketing',
  'Sales',
  'Human Resources',
  'Finance',
  'Operations',
  'Customer Support',
  'Product',
]

export default function ProfilePage() {
  const router = useRouter()
  const { isAuthenticated, currentUser, tickets, updateUser } = useStore()

  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [department, setDepartment] = useState('')
  const [saveMsg, setSaveMsg] = useState('')
  const [saving, setSaving] = useState(false)
  const [isEditing, setIsEditing] = useState(false)

  // Password Update State
  const [currentPass, setCurrentPass] = useState('')
  const [newPass, setNewPass] = useState('')
  const [confirmPass, setConfirmPass] = useState('')
  const [passMsg, setPassMsg] = useState('')
  const [updatingPass, setUpdatingPass] = useState(false)

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/')
    }
  }, [isAuthenticated, router])

  useEffect(() => {
    if (currentUser) {
      setName(currentUser.name)
      setEmail(currentUser.email)
      setDepartment(currentUser.department || '')
    }
  }, [currentUser])

  if (!currentUser) return null

  const handleUpdatePassword = async () => {
    if (!newPass) {
      setPassMsg('Please enter a new password.')
      return
    }
    if (newPass.length < 6) {
      setPassMsg('New password must be at least 6 characters long.')
      return
    }
    if (newPass !== confirmPass) {
      setPassMsg('New password and confirmation do not match.')
      return
    }

    setUpdatingPass(true)
    setPassMsg('')

    try {
      const { supabase } = await import('@/lib/supabase/client')
      const { error } = await supabase.auth.updateUser({ password: newPass })

      if (error) {
        setPassMsg(error.message || 'Failed to update password.')
      } else {
        setPassMsg('Password updated successfully!')
        setCurrentPass('')
        setNewPass('')
        setConfirmPass('')
      }
    } catch (err: any) {
      setPassMsg(err.message || 'Error updating password.')
    } finally {
      setUpdatingPass(false)
    }
  }

  const handleSave = async () => {
    setSaving(true)
    setSaveMsg('')
    await updateUser(currentUser.id, { name, email, department })
    setSaving(false)
    setSaveMsg('Profile saved successfully!')
    setIsEditing(false)
    setTimeout(() => setSaveMsg(''), 3000)
  }

  const handleCancel = () => {
    if (currentUser) {
      setName(currentUser.name)
      setEmail(currentUser.email)
      setDepartment(currentUser.department || '')
    }
    setIsEditing(false)
  }

  const userTickets = tickets.filter(
    t => t.createdBy === currentUser.id || t.assignedTo?.includes(currentUser.id)
  )

  const stats = {
    created: tickets.filter(t => t.createdBy === currentUser.id).length,
    assigned: userTickets.length,
    completed: userTickets.filter(t => t.status === 'completed').length,
    inProgress: userTickets.filter(t => t.status === 'in-progress').length,
  }

  const roleColors = {
    admin: 'bg-red-500/10 text-red-600 border-red-200',
    manager: 'bg-blue-500/10 text-blue-600 border-blue-200',
    employee: 'bg-emerald-500/10 text-emerald-600 border-emerald-200',
    intern: 'bg-purple-500/10 text-purple-600 border-purple-200',
  }

  return (
    <DashboardLayout title="Profile">
      <div className="max-w-4xl mx-auto space-y-6">
        {/* Profile Header */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col md:flex-row items-center md:items-start gap-6">
              <div className="relative">
                <Avatar className="h-24 w-24 border-4 border-background shadow-lg">
                  <AvatarImage src={currentUser.avatar} />
                  <AvatarFallback className="text-2xl bg-primary text-primary-foreground">
                    {currentUser.name.split(' ').map(n => n[0]).join('')}
                  </AvatarFallback>
                </Avatar>
                <Button
                  size="icon"
                  variant="secondary"
                  className="absolute bottom-0 right-0 h-8 w-8 rounded-full shadow"
                >
                  <Camera className="h-4 w-4" />
                </Button>
              </div>
              
              <div className="flex-1 text-center md:text-left">
                <div className="flex flex-col md:flex-row md:items-center gap-2 md:gap-4">
                  <h1 className="text-2xl font-bold">{currentUser.name}</h1>
                  <Badge variant="outline" className={roleColors[currentUser.role]}>
                    <Shield className="h-3 w-3 mr-1" />
                    {currentUser.role.charAt(0).toUpperCase() + currentUser.role.slice(1)}
                  </Badge>
                </div>
                <p className="text-muted-foreground mt-1">{currentUser.email}</p>
                
                <div className="flex flex-wrap justify-center md:justify-start gap-4 mt-4 text-sm text-muted-foreground">
                  <div className="flex items-center gap-1">
                    <Building2 className="h-4 w-4" />
                    {currentUser.department || 'No department'}
                  </div>
                  <div className="flex items-center gap-1">
                    <Calendar className="h-4 w-4" />
                    Joined {format(new Date(currentUser.joinedAt), 'MMMM yyyy')}
                  </div>
                </div>
              </div>

              {isEditing ? (
                <Button variant="ghost" onClick={handleCancel}>Cancel</Button>
              ) : (
                <Button variant="outline" onClick={() => setIsEditing(true)}>Edit Profile</Button>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <Card>
            <CardContent className="pt-6 text-center">
              <Ticket className="h-8 w-8 mx-auto text-primary mb-2" />
              <p className="text-2xl font-bold">{stats.created}</p>
              <p className="text-xs text-muted-foreground">Tickets Created</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6 text-center">
              <User className="h-8 w-8 mx-auto text-blue-500 mb-2" />
              <p className="text-2xl font-bold">{stats.assigned}</p>
              <p className="text-xs text-muted-foreground">Assigned to Me</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6 text-center">
              <CheckCircle className="h-8 w-8 mx-auto text-emerald-500 mb-2" />
              <p className="text-2xl font-bold">{stats.completed}</p>
              <p className="text-xs text-muted-foreground">Completed</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6 text-center">
              <Clock className="h-8 w-8 mx-auto text-amber-500 mb-2" />
              <p className="text-2xl font-bold">{stats.inProgress}</p>
              <p className="text-xs text-muted-foreground">In Progress</p>
            </CardContent>
          </Card>
        </div>

        {/* Profile Details & Password Management */}
        <Card>
          <CardHeader>
            <CardTitle>Profile Settings</CardTitle>
            <CardDescription>Manage your account details and password anytime</CardDescription>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="general" className="space-y-4">
              <TabsList>
                <TabsTrigger value="general">General</TabsTrigger>
                <TabsTrigger value="security" className="flex items-center gap-1.5">
                  <KeyRound className="h-3.5 w-3.5" />
                  Change Password
                </TabsTrigger>
                <TabsTrigger value="notifications">Notifications</TabsTrigger>
              </TabsList>

              <TabsContent value="general" className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Full Name</Label>
                    <Input id="name" value={name} onChange={e => setName(e.target.value)} disabled={!isEditing} />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="email">Email</Label>
                    <Input id="email" type="email" value={email} onChange={e => setEmail(e.target.value)} disabled={!isEditing} />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="department">Department</Label>
                    <Input
                      id="department"
                      value={currentUser.department || 'General'}
                      disabled
                      className="bg-muted"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="role">Role</Label>
                    <Input id="role" defaultValue={currentUser.role} disabled />
                  </div>
                </div>
                {saveMsg && <p className="text-sm text-green-600 font-medium">{saveMsg}</p>}
                {isEditing && (
                  <div className="flex justify-end gap-2">
                    <Button variant="outline" onClick={handleCancel}>Cancel</Button>
                    <Button onClick={handleSave} disabled={saving}>
                      {saving ? 'Saving...' : 'Save Changes'}
                    </Button>
                  </div>
                )}
              </TabsContent>

              <TabsContent value="security" className="space-y-4">
                <div className="p-4 rounded-lg bg-primary/5 border border-primary/20 space-y-1 mb-4">
                  <h4 className="text-sm font-semibold text-primary flex items-center gap-2">
                    <KeyRound className="h-4 w-4" />
                    Change Your Account Password
                  </h4>
                  <p className="text-xs text-muted-foreground">
                    You can change your password at any time whenever you wish. If you don&apos;t want to change it, you can keep your existing password.
                  </p>
                </div>

                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="new-password">New Password</Label>
                    <Input
                      id="new-password"
                      type="password"
                      placeholder="Enter new password (min 6 characters)"
                      value={newPass}
                      onChange={e => setNewPass(e.target.value)}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="confirm-password">Confirm New Password</Label>
                    <Input
                      id="confirm-password"
                      type="password"
                      placeholder="Re-type your new password to confirm"
                      value={confirmPass}
                      onChange={e => setConfirmPass(e.target.value)}
                    />
                  </div>
                </div>
                {passMsg && (
                  <p className={`text-sm font-medium ${passMsg.includes('success') ? 'text-emerald-600' : 'text-destructive'}`}>
                    {passMsg}
                  </p>
                )}
                <div className="flex justify-end">
                  <Button onClick={handleUpdatePassword} disabled={updatingPass} className="gap-2">
                    <KeyRound className="h-4 w-4" />
                    {updatingPass ? 'Updating...' : 'Save New Password'}
                  </Button>
                </div>
              </TabsContent>

              <TabsContent value="notifications" className="space-y-4">
                <p className="text-sm text-muted-foreground">
                  Notification preferences will be available soon.
                </p>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}