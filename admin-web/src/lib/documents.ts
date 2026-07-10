import { authorizedForm, authorizedJson } from './api.ts'

export type DocumentCategory =
  | 'REGULATION'
  | 'SCHOOL_INFO'
  | 'SUBJECT_MATERIAL'
  | 'OTHER'

export type DocumentIngestStatus = 'PENDING' | 'INDEXED' | 'FAILED'

export type AdminDocument = {
  id: string
  title: string
  category: DocumentCategory
  subjectName: string | null
  fileName: string
  mimeType: string
  sizeBytes: number
  ingestStatus: DocumentIngestStatus
  ingestError: string | null
  chunkCount: number | null
  updatedAt: string
}

export type AdminDocumentListResponse = {
  page: number
  size: number
  totalItems: number
  totalPages: number
  items: AdminDocument[]
}

export const documentCategoryLabels: Record<DocumentCategory, string> = {
  REGULATION: 'Nội quy & quy chế',
  SCHOOL_INFO: 'Thông tin trường',
  SUBJECT_MATERIAL: 'Tài liệu môn học',
  OTHER: 'Khác',
}

export const documentIngestStatusLabels: Record<DocumentIngestStatus, string> =
  {
    PENDING: 'Đang xử lý',
    INDEXED: 'Đã lập chỉ mục',
    FAILED: 'Lỗi lập chỉ mục',
  }

export function uploadDocument(params: {
  file: File
  title: string
  category: DocumentCategory
  subjectName?: string
}) {
  const formData = new FormData()
  formData.set('file', params.file)
  formData.set('title', params.title)
  formData.set('category', params.category)
  if (params.subjectName) {
    formData.set('subjectName', params.subjectName)
  }

  return authorizedForm<AdminDocument>('/api/admin/documents', formData)
}

export function fetchDocuments(params: {
  search?: string
  page: number
  size: number
}) {
  const query = new URLSearchParams({
    page: String(params.page),
    size: String(params.size),
  })
  if (params.search) {
    query.set('search', params.search)
  }

  return authorizedJson<AdminDocumentListResponse>(
    `/api/admin/documents?${query.toString()}`,
  )
}

export function deleteDocument(id: string) {
  return authorizedJson<undefined>(`/api/admin/documents/${id}`, {
    method: 'DELETE',
  })
}

export function formatFileSize(sizeBytes: number) {
  if (sizeBytes < 1024) {
    return `${sizeBytes} B`
  }
  if (sizeBytes < 1024 * 1024) {
    return `${Math.round(sizeBytes / 1024)} KB`
  }
  return `${(sizeBytes / (1024 * 1024)).toFixed(1)} MB`
}
