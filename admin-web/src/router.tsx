import {
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
} from '@tanstack/react-router'
import { AdminShell } from './ui/admin-shell.tsx'
import { LoginPage } from './features/auth/login-page.tsx'
import { StudentManagementPage } from './features/students/student-management-page.tsx'

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

const routeTree = rootRoute.addChildren([loginRoute, indexRoute])

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
