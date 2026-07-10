import { authorizedJson } from './api.ts'
import { csvRecords } from './csv.ts'

export type TimetableSlotType = 'SUBJECT' | 'MEAL' | 'ACTIVITY'

export type AdminTimetableSlot = {
  id: string
  className: string
  academicYearName: string
  semesterName: string
  dayIndex: number
  lessonNumber: number
  slotType: TimetableSlotType
  title: string
  subjectCode?: string
  roomName?: string
  teacherName?: string
  startsAt: string
  endsAt: string
  updatedAt: string
}

export type AdminTimetableListResponse = {
  page: number
  size: number
  totalItems: number
  totalPages: number
  items: AdminTimetableSlot[]
}

export type TimetableImportRow = {
  className?: string
  dayIndex: number
  lessonNumber: number
  slotType?: string
  title?: string
  subjectCode?: string
  subjectName?: string
  roomName?: string
  teacherName?: string
  startsAt: string
  endsAt: string
}

export type TimetableImportRequest = {
  academicYearName: string
  semesterName: string
  defaultClassName?: string
  slots: TimetableImportRow[]
}

export type TimetableImportRowResult = {
  rowNumber: number
  className: string
  dayIndex: number
  lessonNumber: number
  status: 'CREATED' | 'UPDATED' | 'SKIPPED'
  message: string
}

export type TimetableImportResponse = {
  totalRows: number
  createdSlots: number
  updatedSlots: number
  skippedRows: number
  rows: TimetableImportRowResult[]
}

export const dayIndexLabels: Record<number, string> = {
  1: 'Thứ hai',
  2: 'Thứ ba',
  3: 'Thứ tư',
  4: 'Thứ năm',
  5: 'Thứ sáu',
  6: 'Thứ bảy',
  7: 'Chủ nhật',
}

export const slotTypeLabels: Record<TimetableSlotType, string> = {
  SUBJECT: 'Môn học',
  MEAL: 'Ăn trưa',
  ACTIVITY: 'Hoạt động',
}

type CsvParseResult = {
  rows: TimetableImportRow[]
  errors: string[]
}

const requiredHeaders = [
  'dayIndex',
  'lessonNumber',
  'startsAt',
  'endsAt',
] as const

const timePattern = /^([01]?\d|2[0-3]):[0-5]\d$/

export function parseTimetableCsv(csv: string): CsvParseResult {
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

  const rows: TimetableImportRow[] = []
  const errors: string[] = []

  records.forEach((record, index) => {
    const rowNumber = index + 2

    const dayIndex = Number(record.dayIndex)
    if (!Number.isInteger(dayIndex) || dayIndex < 1 || dayIndex > 7) {
      errors.push(
        `Dòng ${rowNumber}: dayIndex phải là số 1 (thứ hai) đến 7 (chủ nhật)`,
      )
      return
    }

    const lessonNumber = Number(record.lessonNumber)
    if (
      !Number.isInteger(lessonNumber) ||
      lessonNumber < 1 ||
      lessonNumber > 20
    ) {
      errors.push(`Dòng ${rowNumber}: lessonNumber phải là số từ 1 đến 20`)
      return
    }

    if (!timePattern.test(record.startsAt) || !timePattern.test(record.endsAt)) {
      errors.push(`Dòng ${rowNumber}: startsAt/endsAt phải theo định dạng HH:mm`)
      return
    }

    if (!record.title && !record.subjectCode) {
      errors.push(`Dòng ${rowNumber}: cần cột title hoặc subjectCode`)
      return
    }

    rows.push({
      className: record.className || undefined,
      dayIndex,
      lessonNumber,
      slotType: record.slotType || undefined,
      title: record.title || undefined,
      subjectCode: record.subjectCode || undefined,
      subjectName: record.subjectName || undefined,
      roomName: record.roomName || undefined,
      teacherName: record.teacherName || undefined,
      startsAt: record.startsAt,
      endsAt: record.endsAt,
    })
  })

  return { rows, errors }
}

export function fetchTimetable(params: {
  search: string
  page: number
  size: number
}) {
  const query = new URLSearchParams({
    search: params.search,
    page: String(params.page),
    size: String(params.size),
  })

  return authorizedJson<AdminTimetableListResponse>(
    `/api/admin/timetable?${query.toString()}`,
  )
}

export function importTimetable(request: TimetableImportRequest) {
  return authorizedJson<TimetableImportResponse>('/api/admin/timetable/import', {
    method: 'POST',
    body: JSON.stringify(request),
  })
}
