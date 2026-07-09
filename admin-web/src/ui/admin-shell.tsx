import { Navigate, useNavigate } from '@tanstack/react-router'
import type { ReactNode } from 'react'
import {
  Bell,
  ClipboardList,
  GraduationCap,
  LayoutDashboard,
  LogOut,
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
}

type NavItem = {
  label: string
  icon: LucideIcon
  active: boolean
}

const navItems: NavItem[] = [
  { label: 'Tổng quan', icon: LayoutDashboard, active: false },
  { label: 'Học sinh', icon: Users, active: true },
  { label: 'Thông báo', icon: Bell, active: false },
  { label: 'Đơn từ', icon: ClipboardList, active: false },
]

export function AdminShell({ children }: AdminShellProps) {
  const navigate = useNavigate()
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
                <SidebarMenuButton tooltip={item.label} isActive={item.active}>
                  <item.icon />
                  <span>{item.label}</span>
                </SidebarMenuButton>
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
                  <BreadcrumbLink href="/">Học sinh</BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                  <BreadcrumbPage>Danh sách</BreadcrumbPage>
                </BreadcrumbItem>
              </BreadcrumbList>
            </Breadcrumb>
            <h1 className="truncate text-xl font-semibold tracking-tight">
              Học sinh
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
