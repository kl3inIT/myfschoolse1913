import { authorizedJson } from './api.ts'

export type NotificationCategory = 'ACADEMIC' | 'EVENT' | 'SERVICE' | 'GENERAL'
export type NotificationAudience = 'ALL_STUDENTS' | 'HIGH_SCHOOL'

export type AdminNotification = {
  id: string
  title: string
  body: string
  category: NotificationCategory
  audience: NotificationAudience
  publishedAt: string
  pinned: boolean
  active: boolean
}

export type AdminNotificationListResponse = {
  page: number
  size: number
  totalItems: number
  totalPages: number
  items: AdminNotification[]
}

export type PublishNotificationRequest = {
  title: string
  body: string
  category: NotificationCategory
  audience: NotificationAudience
  pinned: boolean
}

export const notificationCategoryLabels: Record<NotificationCategory, string> =
  {
    ACADEMIC: 'Học tập',
    EVENT: 'Sự kiện',
    SERVICE: 'Dịch vụ',
    GENERAL: 'Chung',
  }

export const notificationAudienceLabels: Record<NotificationAudience, string> =
  {
    ALL_STUDENTS: 'Toàn bộ học sinh',
    HIGH_SCHOOL: 'Khối THPT',
  }

export function publishNotification(request: PublishNotificationRequest) {
  return authorizedJson<AdminNotification>('/api/admin/notifications', {
    method: 'POST',
    body: JSON.stringify(request),
  })
}

export function fetchNotifications(params: { page: number; size: number }) {
  const query = new URLSearchParams({
    page: String(params.page),
    size: String(params.size),
  })

  return authorizedJson<AdminNotificationListResponse>(
    `/api/admin/notifications?${query.toString()}`,
  )
}

export function deactivateNotification(id: string) {
  return authorizedJson<undefined>(`/api/admin/notifications/${id}`, {
    method: 'DELETE',
  })
}
