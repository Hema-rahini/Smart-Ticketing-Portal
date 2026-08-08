'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAppStore as useStore } from '@/lib/store'
import { DashboardLayout } from '@/components/layout/dashboard-layout'
import { UserManagement } from '@/components/users/user-management'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Users, TrendingUp, CheckCircle, Clock } from 'lucide-react'
import { StatsCard } from '@/components/dashboard/stats-card'
import { TeamProductivityChart } from '@/components/dashboard/charts'

export default function TeamPage() {
  const router = useRouter()
  const { isAuthenticated, currentUser, users, tickets } = useStore()

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/')
    }
  }, [isAuthenticated, currentUser, router])

  if (!currentUser) return null

  const teamMembers = users

  const teamTickets = tickets.filter(t =>
    teamMembers.some(m => t.assignedTo?.includes(m.id) || t.createdBy === m.id)
  )

  const stats = {
    totalMembers: users.length,
    activeTickets: teamTickets.filter(t => t.status !== 'closed' && t.status !== 'completed').length,
    completedTickets: teamTickets.filter(t => t.status === 'completed').length,
    productivity: 85,
  }

  return (
    <DashboardLayout title="Team Overview">
      <div className="space-y-6">
        {/* Stats */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatsCard
            title="Team Members"
            value={stats.totalMembers}
            icon={Users}
            description="active members"
          />
          <StatsCard
            title="Active Tickets"
            value={stats.activeTickets}
            icon={Clock}
            description="in progress"
          />
          <StatsCard
            title="Completed"
            value={stats.completedTickets}
            icon={CheckCircle}
            trend={{ value: 12, isPositive: true }}
            description="this month"
          />
          <StatsCard
            title="Productivity"
            value={`${stats.productivity}%`}
            icon={TrendingUp}
            trend={{ value: 5, isPositive: true }}
            description="team average"
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Team Members */}
          <div className="lg:col-span-2">
            <UserManagement
              title="Team Members"
              showAddButton={['admin', 'manager'].includes(currentUser.role)}
              filterRole={currentUser.role === 'manager' ? undefined : undefined}
            />
          </div>

          {/* Team Performance */}
          <div className="space-y-4">
            <TeamProductivityChart />
            
            {/* Quick Stats Card */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Team Highlights</CardTitle>
                <CardDescription>This week&apos;s performance</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {teamMembers.slice(0, 4).map((member) => {
                  const memberTickets = tickets.filter(t => t.assignedTo?.includes(member.id))
                  const completed = memberTickets.filter(t => t.status === 'completed').length

                  return (
                    <div key={member.id} className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <Avatar className="h-8 w-8">
                          <AvatarImage src={member.avatar} />
                          <AvatarFallback className="text-xs bg-primary text-primary-foreground">
                            {member.name.split(' ').map(n => n[0]).join('')}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <p className="text-sm font-medium">{member.name}</p>
                          <p className="text-xs text-muted-foreground capitalize">{member.role}</p>
                        </div>
                      </div>
                      <Badge variant="secondary">{completed} completed</Badge>
                    </div>
                  )
                })}
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </DashboardLayout>
  )
}
