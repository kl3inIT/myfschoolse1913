import { authorizedJson } from './api.ts'

export type ApplicationType =
  | 'ABSENCE'
  | 'LATE_ARRIVAL'
  | 'EARLY_LEAVE'
  | 'DOCUMENT_REQUEST'
  | 'EARLY_PICKUP'
  | 'MEAL_REGISTRATION'

export type ApplicationStatus = 'PENDING' | 'APPROVED' | 'REJECTED'

export type AdminApplication = {
  id: string
  studentCode: string
  fullName: string
  className: string
  academicYearName: string
  type: ApplicationType
  status: ApplicationStatus
  targetDate: string
  requestedTime?: string
  reason: string
  details?: string
  reviewerNote?: string
  createdAt: string
  reviewedAt?: string
}

export type AdminApplicationListResponse = {
  page: number
  size: number
  totalItems: number
  totalPages: number
  items: AdminApplication[]
}

export type AdminApplicationStats = {
  totalApplications: number
  pendingApplications: number
  approvedApplications: number
  rejectedApplications: number
}

export const applicationTypeLabels: Record<ApplicationType, string> = {
  ABSENCE: 'Xin nghỉ học',
  LATE_ARRIVAL: 'Xin vào muộn',
  EARLY_LEAVE: 'Xin về sớm',
  DOCUMENT_REQUEST: 'Xác nhận giấy tờ',
  EARLY_PICKUP: 'Xin đón sớm',
  MEAL_REGISTRATION: 'Dịch vụ ăn trưa',
}

export const applicationStatusLabels: Record<ApplicationStatus, string> = {
  PENDING: 'Chờ duyệt',
  APPROVED: 'Đã duyệt',
  REJECTED: 'Từ chối',
}

export function fetchApplications(params: {
  search: string
  status: string
  page: number
  size: number
}) {
  const query = new URLSearchParams({
    search: params.search,
    status: params.status,
    page: String(params.page),
    size: String(params.size),
  })

  return authorizedJson<AdminApplicationListResponse>(
    `/api/admin/applications?${query.toString()}`,
  )
}

export function fetchApplicationStats() {
  return authorizedJson<AdminApplicationStats>('/api/admin/applications/stats')
}

export function reviewApplication(params: {
  id: string
  decision: 'APPROVED' | 'REJECTED'
  reviewerNote?: string
}) {
  return authorizedJson<AdminApplication>(
    `/api/admin/applications/${params.id}`,
    {
      method: 'PUT',
      body: JSON.stringify({
        decision: params.decision,
        reviewerNote: params.reviewerNote || undefined,
      }),
    },
  )
}
