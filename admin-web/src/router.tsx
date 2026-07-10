import {
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
} from '@tanstack/react-router'
import { AdminShell } from './ui/admin-shell.tsx'
import { LoginPage } from './features/auth/login-page.tsx'
import { ClassManagementPage } from './features/classes/class-management-page.tsx'
import { GradeManagementPage } from './features/grades/grade-management-page.tsx'
import { NotificationManagementPage } from './features/notifications/notification-management-page.tsx'
import { StudentDetailPage } from './features/students/student-detail-page.tsx'
import { StudentManagementPage } from './features/students/student-management-page.tsx'
import { TimetableManagementPage } from './features/timetable/timetable-management-page.tsx'

const rootRoute = createRootRoute({
  component: () => <Outlet />,
})

const loginRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/login',
  component: LoginPage,
})

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  component: () => (
    <AdminShell>
      <StudentManagementPage />
    </AdminShell>
  ),
})

const studentDetailRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/students/$studentId',
  validateSearch: (search: Record<string, unknown>): { edit?: boolean } => ({
    edit: search.edit === true || search.edit === 'true' ? true : undefined,
  }),
  component: () => (
    <AdminShell title="Chi tiết học sinh" breadcrumbPage="Chi tiết">
      <StudentDetailPage />
    </AdminShell>
  ),
})

const notificationsRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/notifications',
  component: () => (
    <AdminShell
      title="Thông báo"
      breadcrumbSection="Thông báo"
      breadcrumbPage="Danh sách"
    >
      <NotificationManagementPage />
    </AdminShell>
  ),
})

const classesRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/classes',
  component: () => (
    <AdminShell
      title="Lớp học"
      breadcrumbSection="Lớp học"
      breadcrumbPage="Danh sách"
    >
      <ClassManagementPage />
    </AdminShell>
  ),
})

const gradesRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/grades',
  component: () => (
    <AdminShell
      title="Điểm số"
      breadcrumbSection="Điểm số"
      breadcrumbPage="Danh sách"
    >
      <GradeManagementPage />
    </AdminShell>
  ),
})

const timetableRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/timetable',
  component: () => (
    <AdminShell
      title="Thời khóa biểu"
      breadcrumbSection="Thời khóa biểu"
      breadcrumbPage="Danh sách"
    >
      <TimetableManagementPage />
    </AdminShell>
  ),
})

const routeTree = rootRoute.addChildren([
  loginRoute,
  indexRoute,
  studentDetailRoute,
  notificationsRoute,
  classesRoute,
  gradesRoute,
  timetableRoute,
])

export const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  scrollRestoration: true,
})

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
