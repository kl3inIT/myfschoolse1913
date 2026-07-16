import { DashboardPage } from '@/features/dashboard/dashboard-page'
import { TeacherWorkspacePage } from '@/features/teacher/teacher-workspace-page'
import { getStoredSession } from '@/lib/api'
import { AdminShell } from '@/ui/admin-shell'

export function HomeRoutePage() {
  const session = getStoredSession()
  if (session?.user.role === 'TEACHER') {
    return (
      <AdminShell
        title="Không gian giáo viên"
        breadcrumbSection="Giáo viên"
        breadcrumbPage="Lớp được phân công"
        allowedRoles={['TEACHER']}
      >
        <TeacherWorkspacePage />
      </AdminShell>
    )
  }

  return (
    <AdminShell
      title="Tổng quan"
      breadcrumbSection="Tổng quan"
      breadcrumbPage="Bảng điều khiển"
      allowedRoles={['ADMIN']}
    >
      <DashboardPage />
    </AdminShell>
  )
}
