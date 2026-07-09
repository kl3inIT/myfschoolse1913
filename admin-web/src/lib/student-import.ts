import { authorizedJson } from './api.ts'

export type StudentImportRow = {
  studentCode: string
  fullName: string
  phoneNumber: string
  academicYearName?: string
  className?: string
  password?: string
  status?: string
}

export type StudentImportRequest = {
  academicYearName: string
  className: string
  defaultPassword: string
  students: StudentImportRow[]
}

export type StudentImportRowResult = {
  rowNumber: number
  phoneNumber: string
  studentCode: string
  status: 'CREATED' | 'UPDATED' | 'SKIPPED'
  message: string
}

export type StudentImportResponse = {
  totalRows: number
  createdUsers: number
  createdStudents: number
  updatedStudents: number
  skippedRows: number
  rows: StudentImportRowResult[]
}

type CsvParseResult = {
  rows: StudentImportRow[]
  errors: string[]
}

const requiredHeaders = ['studentCode', 'fullName', 'phoneNumber'] as const

export function parseStudentsCsv(csv: string): CsvParseResult {
  const lines = csv
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)

  if (lines.length === 0) {
    return { rows: [], errors: ['File CSV đang trống'] }
  }

  const headers = splitCsvLine(lines[0]).map((header) => header.trim())
  const missingHeaders = requiredHeaders.filter(
    (header) => !headers.includes(header),
  )
  if (missingHeaders.length > 0) {
    return {
      rows: [],
      errors: [`Thiếu cột bắt buộc: ${missingHeaders.join(', ')}`],
    }
  }

  const rows: StudentImportRow[] = []
  const errors: string[] = []

  lines.slice(1).forEach((line, index) => {
    const values = splitCsvLine(line)
    const record = Object.fromEntries(
      headers.map((header, valueIndex) => [header, values[valueIndex]?.trim() ?? '']),
    )

    const rowNumber = index + 2
    const studentCode = record.studentCode
    const fullName = record.fullName
    const phoneNumber = record.phoneNumber

    if (!studentCode || !fullName || !phoneNumber) {
      errors.push(`Dòng ${rowNumber}: thiếu studentCode, fullName hoặc phoneNumber`)
      return
    }

    rows.push({
      studentCode,
      fullName,
      phoneNumber,
      academicYearName: optionalValue(record.academicYearName),
      className: optionalValue(record.className),
      password: optionalValue(record.password),
      status: optionalValue(record.status),
    })
  })

  return { rows, errors }
}

export function importStudents(request: StudentImportRequest) {
  return authorizedJson<StudentImportResponse>('/api/admin/students/import', {
    method: 'POST',
    body: JSON.stringify(request),
  })
}

function optionalValue(value: string | undefined) {
  const trimmed = value?.trim()
  return trimmed ? trimmed : undefined
}

function splitCsvLine(line: string) {
  const values: string[] = []
  let current = ''
  let inQuotes = false

  for (let index = 0; index < line.length; index += 1) {
    const char = line[index]
    const nextChar = line[index + 1]

    if (char === '"' && inQuotes && nextChar === '"') {
      current += '"'
      index += 1
      continue
    }

    if (char === '"') {
      inQuotes = !inQuotes
      continue
    }

    if (char === ',' && !inQuotes) {
      values.push(current)
      current = ''
      continue
    }

    current += char
  }

  values.push(current)
  return values
}
