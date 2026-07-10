import { authorizedJson } from './api.ts'
import { csvRecords } from './csv.ts'

export type GradeImportRow = {
  studentCode: string
  subjectCode: string
  subjectName?: string
  formativeScore?: number
  midtermScore?: number
  finalScore?: number
  averageScore?: number
  teacherComment?: string
}

export type GradeImportRequest = {
  academicYearName: string
  semesterName: string
  grades: GradeImportRow[]
}

export type GradeImportRowResult = {
  rowNumber: number
  studentCode: string
  subjectCode: string
  status: 'CREATED' | 'UPDATED' | 'SKIPPED'
  message: string
}

export type GradeImportResponse = {
  totalRows: number
  createdGrades: number
  updatedGrades: number
  skippedRows: number
  rows: GradeImportRowResult[]
}

export type AdminGrade = {
  id: string
  studentCode: string
  fullName: string
  className: string
  academicYearName: string
  semesterName: string
  subjectCode: string
  subjectName: string
  formativeScore?: number
  midtermScore?: number
  finalScore?: number
  averageScore: number
  teacherComment?: string
  updatedAt: string
}

export type AdminGradeListResponse = {
  page: number
  size: number
  totalItems: number
  totalPages: number
  items: AdminGrade[]
}

type CsvParseResult = {
  rows: GradeImportRow[]
  errors: string[]
}

const requiredHeaders = ['studentCode', 'subjectCode'] as const
const scoreColumns = [
  'formativeScore',
  'midtermScore',
  'finalScore',
  'averageScore',
] as const

export function parseGradesCsv(csv: string): CsvParseResult {
  const { headers, records } = csvRecords(csv)

  if (records.length === 0 && headers.length === 0) {
    return { rows: [], errors: ['File CSV đang trống'] }
  }

  const missingHeaders = requiredHeaders.filter(
    (header) => !headers.includes(header),
  )
  if (missingHeaders.length > 0) {
    return {
      rows: [],
      errors: [`Thiếu cột bắt buộc: ${missingHeaders.join(', ')}`],
    }
  }

  const rows: GradeImportRow[] = []
  const errors: string[] = []

  records.forEach((record, index) => {
    const rowNumber = index + 2
    const studentCode = record.studentCode
    const subjectCode = record.subjectCode

    if (!studentCode || !subjectCode) {
      errors.push(`Dòng ${rowNumber}: thiếu studentCode hoặc subjectCode`)
      return
    }

    const scores: Partial<Record<(typeof scoreColumns)[number], number>> = {}
    for (const column of scoreColumns) {
      const raw = record[column]
      if (!raw) {
        continue
      }
      const value = Number(raw.replace(',', '.'))
      if (Number.isNaN(value) || value < 0 || value > 10) {
        errors.push(`Dòng ${rowNumber}: ${column} phải là số từ 0 đến 10`)
        return
      }
      scores[column] = value
    }

    rows.push({
      studentCode,
      subjectCode,
      subjectName: record.subjectName || undefined,
      teacherComment: record.teacherComment || undefined,
      ...scores,
    })
  })

  return { rows, errors }
}

export function fetchGrades(params: {
  search: string
  page: number
  size: number
}) {
  const query = new URLSearchParams({
    search: params.search,
    page: String(params.page),
    size: String(params.size),
  })

  return authorizedJson<AdminGradeListResponse>(
    `/api/admin/grades?${query.toString()}`,
  )
}

export function importGrades(request: GradeImportRequest) {
  return authorizedJson<GradeImportResponse>('/api/admin/grades/import', {
    method: 'POST',
    body: JSON.stringify(request),
  })
}
