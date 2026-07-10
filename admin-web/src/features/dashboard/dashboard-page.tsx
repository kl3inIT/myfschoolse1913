import { useQuery } from '@tanstack/react-query'
import { Link } from '@tanstack/react-router'
import {
  ArrowRight,
  Bell,
  ClipboardList,
  Clock,
  Lock,
  Pin,
  School,
  Users,
} from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Empty,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from '@/components/ui/empty'
import { Skeleton } from '@/components/ui/skeleton'
import {
  applicationTypeLabels,
  fetchApplications,
  fetchApplicationStats,
  type AdminApplication,
} from '@/lib/applications'
import {
  fetchNotifications,
  notificationCategoryLabels,
  type AdminNotification,
} from '@/lib/notifications'
import { fetchStudentStats } from '@/lib/students'

export function DashboardPage() {
  const studentStatsQuery = useQuery({
    queryKey: ['admin-students', 'stats'],
    queryFn: fetchStudentStats,
  })

  const applicationStatsQuery = useQuery({
    queryKey: ['admin-applications', 'stats'],
    queryFn: fetchApplicationStats,
  })

  const pendingApplicationsQuery = useQuery({
    queryKey: ['admin-applications', 'dashboard'],
    queryFn: () =>
      fetchApplications({ search: '', status: 'PENDING', page: 0, size: 5 }),
  })

  const notificationsQuery = useQuery({
    queryKey: ['admin-notifications', 'dashboard'],
    queryFn: () => fetchNotifications({ page: 0, size: 5 }),
  })

  const statsLoading =
    studentStatsQuery.isPending || applicationStatsQuery.isPending

  const stats = [
    {
      label: 'Tổng học sinh',
      value: studentStatsQuery.data?.totalStudents,
      icon: Users,
    },
    {
      label: 'Số lớp',
      value: studentStatsQuery.data?.totalClasses,
      icon: School,
    },
    {
      label: 'Đơn chờ duyệt',
      value: applicationStatsQuery.data?.pendingApplications,
      icon: Clock,
    },
    {
      label: 'Tài khoản khóa',
      value: studentStatsQuery.data?.lockedAccounts,
      icon: Lock,
    },
  ]

  return (
    <div className="flex h-[calc(100svh-8rem)] flex-col gap-4">
      <section className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        {stats.map((item) => (
          <div
            key={item.label}
            className="flex items-center gap-3 rounded-md border bg-background p-4"
          >
            <div className="flex size-9 shrink-0 items-center justify-center rounded-md bg-muted">
              <item.icon className="size-4 text-muted-foreground" />
            </div>
            <div className="min-w-0">
              <p className="text-xs text-muted-foreground">{item.label}</p>
              {statsLoading ? (
                <Skeleton className="mt-1 h-6 w-12" />
              ) : (
                <p className="text-xl font-semibold tabular-nums">
                  {item.value ?? 0}
                </p>
              )}
            </div>
          </div>
        ))}
      </section>

      <section className="grid min-h-0 flex-1 gap-4 lg:grid-cols-2">
        <DashboardPanel
          title="Đơn từ chờ duyệt"
          linkTo="/applications"
          isLoading={pendingApplicationsQuery.isPending}
          isEmpty={(pendingApplicationsQuery.data?.items.length ?? 0) === 0}
          empty={
            <Empty className="min-h-40 border-0">
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <ClipboardList />
                </EmptyMedia>
                <EmptyTitle>Không có đơn chờ duyệt</EmptyTitle>
                <EmptyDescription>
                  Đơn học sinh gửi từ app sẽ xuất hiện tại đây.
                </EmptyDescription>
              </EmptyHeader>
            </Empty>
          }
        >
          {(pendingApplicationsQuery.data?.items ?? []).map((application) => (
            <PendingApplicationRow
              key={application.id}
              application={application}
            />
          ))}
        </DashboardPanel>

        <DashboardPanel
          title="Thông báo mới nhất"
          linkTo="/notifications"
          isLoading={notificationsQuery.isPending}
          isEmpty={(notificationsQuery.data?.items.length ?? 0) === 0}
          empty={
            <Empty className="min-h-40 border-0">
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <Bell />
                </EmptyMedia>
                <EmptyTitle>Chưa có thông báo</EmptyTitle>
                <EmptyDescription>
                  Đăng thông báo đầu tiên từ trang Thông báo.
                </EmptyDescription>
              </EmptyHeader>
            </Empty>
          }
        >
          {(notificationsQuery.data?.items ?? []).map((notification) => (
            <NotificationRow
              key={notification.id}
              notification={notification}
            />
          ))}
        </DashboardPanel>
      </section>
    </div>
  )
}

function DashboardPanel({
  title,
  linkTo,
  isLoading,
  isEmpty,
  empty,
  children,
}: {
  title: string
  linkTo: string
  isLoading: boolean
  isEmpty: boolean
  empty: React.ReactNode
  children: React.ReactNode
}) {
  return (
    <div className="flex min-h-0 min-w-0 flex-col rounded-md border bg-background">
      <div className="flex shrink-0 items-center justify-between border-b px-4 py-2.5">
        <h2 className="text-sm font-semibold">{title}</h2>
        <Button asChild type="button" variant="ghost" size="sm">
          <Link to={linkTo}>
            Xem tất cả
            <ArrowRight className="size-3.5" />
          </Link>
        </Button>
      </div>
      <div className="min-h-0 flex-1 overflow-auto">
        {isLoading ? (
          <div className="space-y-3 p-4">
            {Array.from({ length: 4 }, (_, index) => (
              <div key={index} className="flex items-center gap-4">
                <Skeleton className="h-4 flex-1" />
                <Skeleton className="h-4 w-24" />
              </div>
            ))}
          </div>
        ) : isEmpty ? (
          empty
        ) : (
          <ul className="divide-y">{children}</ul>
        )}
      </div>
    </div>
  )
}

function PendingApplicationRow({
  application,
}: {
  application: AdminApplication
}) {
  return (
    <li className="flex items-center gap-3 px-4 py-3">
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-medium">
          {application.fullName}
          <span className="ml-1.5 text-xs font-normal text-muted-foreground">
            {application.studentCode} · {application.className}
          </span>
        </p>
        <p className="truncate text-xs text-muted-foreground">
          {application.reason}
        </p>
      </div>
      <Badge variant="outline" className="shrink-0">
        {applicationTypeLabels[application.type]}
      </Badge>
      <span className="shrink-0 text-xs tabular-nums text-muted-foreground">
        {formatDate(application.targetDate)}
      </span>
    </li>
  )
}

function NotificationRow({
  notification,
}: {
  notification: AdminNotification
}) {
  return (
    <li
      className={`flex items-center gap-3 px-4 py-3 ${notification.active ? '' : 'opacity-60'}`}
    >
      <div className="min-w-0 flex-1">
        <p className="flex items-center gap-1.5 text-sm font-medium">
          {notification.pinned ? (
            <Pin className="size-3.5 shrink-0 text-muted-foreground" />
          ) : null}
          <span className="truncate">{notification.title}</span>
        </p>
        <p className="truncate text-xs text-muted-foreground">
          {notification.body}
        </p>
      </div>
      <Badge variant="outline" className="shrink-0">
        {notificationCategoryLabels[notification.category]}
      </Badge>
      {notification.active ? null : (
        <Badge variant="outline" className="shrink-0">
          Đã thu hồi
        </Badge>
      )}
      <span className="shrink-0 text-xs tabular-nums text-muted-foreground">
        {formatInstant(notification.publishedAt)}
      </span>
    </li>
  )
}

function formatDate(date: string) {
  return new Date(`${date}T00:00:00`).toLocaleDateString('vi-VN')
}

function formatInstant(instant: string) {
  return new Date(instant).toLocaleDateString('vi-VN')
}
