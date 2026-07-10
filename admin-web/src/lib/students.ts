import { authorizedJson } from './api.ts'

export type AdminStudent = {
  id: string
  studentCode: string
  fullName: string
  phoneNumber: string
  className: string
  academicYearName: string
  status: string
  accountEnabled: boolean
}

export type AdminStudentListResponse = {
  page: number
  size: number
  totalItems: number
  totalPages: number
  items: AdminStudent[]
}

export type AdminStudentStats = {
  totalStudents: number
  activeStudents: number
  lockedAccounts: number
  totalClasses: number
}

export function fetchStudentStats() {
  return authorizedJson<AdminStudentStats>('/api/admin/students/stats')
}

export function fetchStudent(id: string) {
  return authorizedJson<AdminStudent>(`/api/admin/students/${id}`)
}

export type UpdateStudentRequest = {
  fullName: string
  phoneNumber: string
  studentCode: string
  academicYearName: string
  className: string
  status: string
  accountEnabled: boolean
  newPassword?: string
}

export function updateStudent(id: string, request: UpdateStudentRequest) {
  return authorizedJson<AdminStudent>(`/api/admin/students/${id}`, {
    method: 'PUT',
    body: JSON.stringify(request),
  })
}

export function fetchStudents(params: {
  search: string
  page: number
  size: number
}) {
  const query = new URLSearchParams({
    search: params.search,
    page: String(params.page),
    size: String(params.size),
  })

  return authorizedJson<AdminStudentListResponse>(
    `/api/admin/students?${query.toString()}`,
  )
}
