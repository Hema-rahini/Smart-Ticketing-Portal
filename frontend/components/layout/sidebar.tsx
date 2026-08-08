'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils'
import { useAppStore as useStore } from '@/lib/store'
import { useTranslation } from '@/lib/i18n'
import type { UserRole } from '@smart-ticketing/shared'
import {
  LayoutDashboard,
  Ticket,
  Users,
  MessageSquare,
  BarChart3,
  Bell,
  Settings,
  Building2,
  Megaphone,
  CheckSquare,
  FolderKanban,
  UserCircle,
  ChevronLeft,
  ChevronRight,
  LogOut,
  Calendar,
  CalendarDays,
  HelpCircle,
  Award,
  ClipboardCheck,
  BookOpen,
  FileBarChart,
  Briefcase,
  Trophy,
  ClipboardList,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'
import { ScrollArea } from '@/components/ui/scroll-area'
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip'

interface NavItem {
  titleKey: string
  defaultTitle: string
  href: string
  icon: React.ComponentType<{ className?: string }>
  roles: UserRole[]
}

const navItems: NavItem[] = [
  { titleKey: 'dashboard', defaultTitle: 'Dashboard', href: '/dashboard', icon: LayoutDashboard, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'tickets', defaultTitle: 'Tickets', href: '/tickets', icon: Ticket, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'calendar', defaultTitle: 'Calendar', href: '/calendar', icon: Calendar, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'myTasks', defaultTitle: 'My Tasks', href: '/tasks', icon: CheckSquare, roles: ['employee', 'intern'] },
  { titleKey: 'leaveAttendance', defaultTitle: 'Leave & Attendance', href: '/leave', icon: CalendarDays, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'team', defaultTitle: 'Team', href: '/team', icon: Users, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'collaboration', defaultTitle: 'Collaboration', href: '/collaboration', icon: FolderKanban, roles: ['manager', 'employee'] },
  { titleKey: 'performance', defaultTitle: 'Performance Reviews', href: '/performance', icon: Award, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'onboarding', defaultTitle: 'Onboarding', href: '/onboarding', icon: ClipboardCheck, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'chat', defaultTitle: 'Chat', href: '/chat', icon: MessageSquare, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'analytics', defaultTitle: 'Analytics', href: '/analytics', icon: BarChart3, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'announcements', defaultTitle: 'Announcements', href: '/announcements', icon: Megaphone, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'knowledgeBase', defaultTitle: 'Knowledge Base', href: '/knowledge-base', icon: BookOpen, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'support', defaultTitle: 'Help & Support', href: '/support', icon: HelpCircle, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'reports', defaultTitle: 'Reports', href: '/reports', icon: FileBarChart, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'projects', defaultTitle: 'Projects', href: '/projects', icon: Briefcase, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'leaderboard', defaultTitle: 'Leaderboard', href: '/leaderboard', icon: Trophy, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'surveys', defaultTitle: 'Surveys', href: '/surveys', icon: ClipboardList, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'departments', defaultTitle: 'Departments', href: '/departments', icon: Building2, roles: ['admin'] },
  { titleKey: 'userManagement', defaultTitle: 'User Management', href: '/users', icon: Users, roles: ['admin'] },
]

const bottomNavItems: NavItem[] = [
  { titleKey: 'notifications', defaultTitle: 'Notifications', href: '/notifications', icon: Bell, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'profile', defaultTitle: 'Profile', href: '/profile', icon: UserCircle, roles: ['admin', 'manager', 'employee', 'intern'] },
  { titleKey: 'settings', defaultTitle: 'Settings', href: '/settings', icon: Settings, roles: ['admin', 'manager', 'employee', 'intern'] },
]

export function Sidebar() {
  const pathname = usePathname()
  const { currentUser, sidebarOpen, setSidebarOpen, logout } = useStore()
  const { t } = useTranslation()
  
  if (!currentUser) return null
  
  const filteredNavItems = navItems.filter(item => item.roles.includes(currentUser.role))
  const filteredBottomItems = bottomNavItems.filter(item => item.roles.includes(currentUser.role))

  const NavLink = ({ item }: { item: NavItem }) => {
    const isActive = pathname === item.href || pathname.startsWith(`${item.href}/`)
    const Icon = item.icon
    const title = t(item.titleKey) || item.defaultTitle
    
    const linkContent = (
      <Link
        href={item.href}
        className={cn(
          'flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all duration-200',
          'hover:bg-sidebar-accent hover:text-sidebar-accent-foreground',
          isActive
            ? 'bg-sidebar-primary text-sidebar-primary-foreground shadow-sm'
            : 'text-sidebar-foreground/70'
        )}
      >
        <Icon className="h-5 w-5 shrink-0" />
        {sidebarOpen && <span className="truncate">{title}</span>}
      </Link>
    )
    
    if (!sidebarOpen) {
      return (
        <Tooltip delayDuration={0}>
          <TooltipTrigger asChild>{linkContent}</TooltipTrigger>
          <TooltipContent side="right" className="font-medium">
            {title}
          </TooltipContent>
        </Tooltip>
      )
    }
    
    return linkContent
  }

  return (
    <TooltipProvider>
      <aside
        className={cn(
          'fixed left-0 top-0 z-40 h-screen bg-sidebar border-r border-sidebar-border transition-all duration-300 ease-in-out',
          sidebarOpen ? 'w-64' : 'w-[72px]'
        )}
      >
        <div className="flex h-full flex-col">
          {/* Header */}
          <div className="flex h-16 items-center justify-between px-4 border-b border-sidebar-border">
            {sidebarOpen && (
              <div className="flex items-center gap-2">
                <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-sidebar-primary">
                  <Ticket className="h-4 w-4 text-sidebar-primary-foreground" />
                </div>
                <span className="font-semibold text-sidebar-foreground">SmartTicket</span>
              </div>
            )}
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="h-8 w-8 text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
            >
              {sidebarOpen ? <ChevronLeft className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
            </Button>
          </div>

          {/* User Info */}
          <div className={cn('px-3 py-4', !sidebarOpen && 'flex justify-center')}>
            <div className={cn('flex items-center gap-3', !sidebarOpen && 'flex-col')}>
              <Avatar className="h-10 w-10 border-2 border-sidebar-accent">
                <AvatarImage src={currentUser.avatar} />
                <AvatarFallback className="bg-sidebar-primary text-sidebar-primary-foreground text-sm font-medium">
                  {currentUser.name.split(' ').map(n => n[0]).join('')}
                </AvatarFallback>
              </Avatar>
              {sidebarOpen && (
                <div className="flex-1 overflow-hidden">
                  <p className="truncate text-sm font-medium text-sidebar-foreground">
                    {currentUser.name}
                  </p>
                  <p className="truncate text-xs text-sidebar-foreground/60 capitalize">
                    {currentUser.role}
                  </p>
                </div>
              )}
            </div>
          </div>

          <Separator className="bg-sidebar-border" />

          {/* Main Navigation */}
          <ScrollArea className="flex-1 px-3 py-4">
            <nav className="flex flex-col gap-1">
              {filteredNavItems.map((item) => (
                <NavLink key={item.href} item={item} />
              ))}
            </nav>
          </ScrollArea>

          <Separator className="bg-sidebar-border" />

          {/* Bottom Navigation */}
          <div className="px-3 py-4">
            <nav className="flex flex-col gap-1">
              {filteredBottomItems.map((item) => (
                <NavLink key={item.href} item={item} />
              ))}
              <button
                onClick={logout}
                className={cn(
                  'flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all duration-200',
                  'text-sidebar-foreground/70 hover:bg-destructive/10 hover:text-destructive'
                )}
              >
                <LogOut className="h-5 w-5 shrink-0" />
                {sidebarOpen && <span>{t('logout')}</span>}
              </button>
            </nav>
          </div>
        </div>
      </aside>
    </TooltipProvider>
  )
}
