import { authorizedJson } from './api.ts'

export type AdminSchoolClass = {
  id: string
  name: string
  studentCount: number
}

export type AdminAcademicYear = {
  id: string
  name: string
  startsOn: string | null
  endsOn: string | null
  currentYear: boolean
  classes: AdminSchoolClass[]
}

export type AdminAcademicYearsResponse = {
  years: AdminAcademicYear[]
}

export type CreateAcademicYearRequest = {
  name: string
  startsOn?: string
  endsOn?: string
  currentYear: boolean
}

export function fetchAcademicYears() {
  return authorizedJson<AdminAcademicYearsResponse>('/api/admin/academic-years')
}

export function createAcademicYear(request: CreateAcademicYearRequest) {
  return authorizedJson<AdminAcademicYear>('/api/admin/academic-years', {
    method: 'POST',
    body: JSON.stringify(request),
  })
}

export function createSchoolClass(params: { yearId: string; name: string }) {
  return authorizedJson<AdminSchoolClass>(
    `/api/admin/academic-years/${params.yearId}/classes`,
    {
      method: 'POST',
      body: JSON.stringify({ name: params.name }),
    },
  )
}
