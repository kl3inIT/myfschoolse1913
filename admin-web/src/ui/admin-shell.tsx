import {
  Link,
  Navigate,
  useNavigate,
  useRouterState,
} from '@tanstack/react-router'
import type { ReactNode } from 'react'
import {
  Bell,
  BookOpenCheck,
  CalendarDays,
  ClipboardList,
  GraduationCap,
  LayoutDashboard,
  LogOut,
  School,
  Users,
  type LucideIcon,
} from 'lucide-react'
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from '@/components/ui/breadcrumb'
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarInset,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarProvider,
  SidebarRail,
  SidebarTrigger,
} from '@/components/ui/sidebar'
import { clearSession, getStoredSession } from '@/lib/api'

type AdminShellProps = {
  children: ReactNode
  title?: string
  breadcrumbSection?: string
  breadcrumbPage?: string
}

type NavItem = {
  label: string
  icon: LucideIcon
  to?: string
  matchPrefixes?: string[]
}

const navItems: NavItem[] = [
  { label: 'Tổng quan', icon: LayoutDashboard, to: '/' },
  {
    label: 'Học sinh',
    icon: Users,
    to: '/students',
    matchPrefixes: ['/students'],
  },
  {
    label: 'Lớp học',
    icon: School,
    to: '/classes',
    matchPrefixes: ['/classes'],
  },
  {
    label: 'Điểm số',
    icon: BookOpenCheck,
    to: '/grades',
    matchPrefixes: ['/grades'],
  },
  {
    label: 'Thời khóa biểu',
    icon: CalendarDays,
    to: '/timetable',
    matchPrefixes: ['/timetable'],
  },
  {
    label: 'Thông báo',
    icon: Bell,
    to: '/notifications',
    matchPrefixes: ['/notifications'],
  },
  {
    label: 'Đơn từ',
    icon: ClipboardList,
    to: '/applications',
    matchPrefixes: ['/applications'],
  },
]

function isNavItemActive(item: NavItem, pathname: string) {
  if (!item.to) {
    return false
  }
  if (item.to === pathname) {
    return true
  }
  return (item.matchPrefixes ?? []).some((prefix) =>
    pathname.startsWith(prefix),
  )
}

export function AdminShell({
  children,
  title = 'Học sinh',
  breadcrumbSection = 'Học sinh',
  breadcrumbPage = 'Danh sách',
}: AdminShellProps) {
  const navigate = useNavigate()
  const pathname = useRouterState({
    select: (state) => state.location.pathname,
  })
  const session = getStoredSession()

  if (!session || session.user.role !== 'ADMIN') {
    return <Navigate to="/login" />
  }

  function logout() {
    clearSession()
    void navigate({ to: '/login' })
  }

  return (
    <SidebarProvider>
      <Sidebar collapsible="icon">
        <SidebarHeader>
          <div className="flex items-center gap-2 px-1 py-1 group-data-[collapsible=icon]:justify-center group-data-[collapsible=icon]:px-0">
            <div className="flex size-7 shrink-0 items-center justify-center rounded-md border bg-background">
              <GraduationCap className="size-4" />
            </div>
            <div className="min-w-0 group-data-[collapsible=icon]:hidden">
              <p className="text-xs text-muted-foreground">MyFSchool</p>
              <p className="truncate text-sm font-semibold">Bảng quản trị</p>
            </div>
          </div>
        </SidebarHeader>

        <SidebarContent>
          <SidebarMenu className="px-2">
            {navItems.map((item) => (
              <SidebarMenuItem key={item.label}>
                {item.to ? (
                  <SidebarMenuButton
                    asChild
                    tooltip={item.label}
                    isActive={isNavItemActive(item, pathname)}
                  >
                    <Link to={item.to}>
                      <item.icon />
                      <span>{item.label}</span>
                    </Link>
                  </SidebarMenuButton>
                ) : (
                  <SidebarMenuButton tooltip={item.label} disabled>
                    <item.icon />
                    <span>{item.label}</span>
                  </SidebarMenuButton>
                )}
              </SidebarMenuItem>
            ))}
          </SidebarMenu>
        </SidebarContent>

        <SidebarFooter>
          <div className="px-2 py-1 group-data-[collapsible=icon]:hidden">
            <div className="flex items-start justify-between gap-2">
              <div className="min-w-0">
                <p className="truncate text-sm font-medium">
                  {session.user.fullName}
                </p>
                <p className="truncate text-xs text-muted-foreground">
                  {session.user.phoneNumber}
                </p>
              </div>
              <p className="shrink-0 text-xs font-medium text-muted-foreground">
                {adminRoleLabel(session.user.role)}
              </p>
            </div>
          </div>
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton tooltip="Đăng xuất" onClick={logout}>
                <LogOut />
                <span>Đăng xuất</span>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarFooter>
        <SidebarRail />
      </Sidebar>

      <SidebarInset>
        <header className="flex min-h-16 shrink-0 items-center gap-3 border-b px-4 lg:px-6">
          <SidebarTrigger className="md:hidden" />
          <div className="min-w-0 flex-1 space-y-1">
            <Breadcrumb>
              <BreadcrumbList>
                <BreadcrumbItem>
                  <BreadcrumbLink href="/">Quản trị</BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                  <BreadcrumbLink href="/">{breadcrumbSection}</BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                  <BreadcrumbPage>{breadcrumbPage}</BreadcrumbPage>
                </BreadcrumbItem>
              </BreadcrumbList>
            </Breadcrumb>
            <h1 className="truncate text-xl font-semibold tracking-tight">
              {title}
            </h1>
          </div>
        </header>

        <div className="min-w-0 flex-1 p-4 lg:p-6">{children}</div>
      </SidebarInset>
    </SidebarProvider>
  )
}

function adminRoleLabel(role: string) {
  return role === 'ADMIN' ? 'QUẢN TRỊ' : role
}
