import { zodResolver } from '@hookform/resolvers/zod'
import {
  keepPreviousData,
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import { useMemo, useRef, useState } from 'react'
import { useForm } from 'react-hook-form'
import { toast } from 'sonner'
import { z } from 'zod'
import { FileText, Loader2, Search, Upload } from 'lucide-react'
import { DataTable, DataTablePagination } from '@/components/data-table'
import { documentColumns } from './columns'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import {
  Empty,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from '@/components/ui/empty'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  deleteDocument,
  documentCategoryLabels,
  fetchDocuments,
  uploadDocument,
  type AdminDocument,
} from '@/lib/documents'

const pageSize = 20

const uploadSchema = z.object({
  title: z.string().trim().max(200, 'Tiêu đề tối đa 200 ký tự'),
  category: z.enum(['REGULATION', 'SCHOOL_INFO', 'SUBJECT_MATERIAL', 'OTHER']),
  subjectName: z.string().trim().max(120, 'Tên môn tối đa 120 ký tự'),
})

type UploadForm = z.infer<typeof uploadSchema>

export function DocumentManagementPage() {
  const [page, setPage] = useState(0)
  const [search, setSearch] = useState('')
  const queryClient = useQueryClient()

  const documentsQuery = useQuery({
    queryKey: ['admin-documents', 'list', page, search],
    queryFn: () => fetchDocuments({ search, page, size: pageSize }),
    placeholderData: keepPreviousData,
  })

  const deleteMutation = useMutation({
    mutationFn: deleteDocument,
    onSuccess: () => {
      toast.success('Đã xóa tài liệu khỏi kho tri thức')
      queryClient.invalidateQueries({ queryKey: ['admin-documents'] })
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Xóa tài liệu thất bại',
      )
    },
  })

  return (
    <div className="flex h-full min-h-0 flex-col gap-4">
      <section className="flex items-center justify-between gap-3">
        <div className="relative w-full max-w-sm">
          <Search className="absolute left-2.5 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            value={search}
            placeholder="Tìm theo tiêu đề, tên file, môn học"
            className="pl-8"
            onChange={(event) => {
              setSearch(event.target.value)
              setPage(0)
            }}
          />
        </div>
        <UploadDocumentDialog />
      </section>

      <section className="flex min-h-0 min-w-0 flex-1 flex-col">
        <DocumentListPanel
          isLoading={documentsQuery.isPending}
          page={page}
          result={documentsQuery.data}
          deletingId={
            deleteMutation.isPending ? deleteMutation.variables : undefined
          }
          onDelete={(document) => deleteMutation.mutate(document.id)}
          onPageChange={setPage}
        />
      </section>
    </div>
  )
}

function UploadDocumentDialog() {
  const [open, setOpen] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [fileError, setFileError] = useState<string>()
  const queryClient = useQueryClient()

  const form = useForm<UploadForm>({
    resolver: zodResolver(uploadSchema),
    defaultValues: {
      title: '',
      category: 'SUBJECT_MATERIAL',
      subjectName: '',
    },
  })

  const uploadMutation = useMutation({
    mutationFn: uploadDocument,
    onSuccess: (document) => {
      toast.success(`Đã tải lên "${document.title}"`)
      form.reset()
      queryClient.invalidateQueries({ queryKey: ['admin-documents'] })
      setOpen(false)
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Tải tài liệu thất bại',
      )
    },
  })

  function changeOpen(nextOpen: boolean) {
    setOpen(nextOpen)
    if (nextOpen) {
      form.reset()
      setFileError(undefined)
    }
  }

  function submit(values: UploadForm) {
    const file = fileInputRef.current?.files?.[0]
    if (!file) {
      setFileError('Vui lòng chọn file tài liệu')
      return
    }
    setFileError(undefined)
    uploadMutation.mutate({
      file,
      title: values.title || file.name,
      category: values.category,
      subjectName: values.subjectName || undefined,
    })
  }

  return (
    <Dialog open={open} onOpenChange={changeOpen}>
      <DialogTrigger asChild>
        <Button type="button">
          <Upload className="size-4" />
          Tải tài liệu
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>Tải tài liệu vào kho tri thức</DialogTitle>
          <DialogDescription>
            Trợ lý AI của học sinh sẽ dùng tài liệu này để trả lời các câu hỏi
            về trường và môn học. Hỗ trợ PDF, Word, text/Markdown.
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form
            id="upload-document-form"
            onSubmit={form.handleSubmit(submit)}
            className="space-y-4"
            noValidate
          >
            <FormItem>
              <FormLabel>File tài liệu</FormLabel>
              <FormControl>
                <Input
                  ref={fileInputRef}
                  type="file"
                  accept=".pdf,.doc,.docx,.rtf,.txt,.md"
                  onChange={(event) => {
                    setFileError(undefined)
                    const file = event.target.files?.[0]
                    if (file && !form.getValues('title')) {
                      form.setValue('title', file.name.replace(/\.[^.]+$/, ''))
                    }
                  }}
                />
              </FormControl>
              {fileError ? (
                <p className="text-sm text-destructive">{fileError}</p>
              ) : null}
            </FormItem>

            <FormField
              control={form.control}
              name="title"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Tiêu đề</FormLabel>
                  <FormControl>
                    <Input
                      autoComplete="off"
                      placeholder="VD: Quy chế thi lại 2026"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="grid gap-4 sm:grid-cols-2">
              <FormField
                control={form.control}
                name="category"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Loại tài liệu</FormLabel>
                    <Select value={field.value} onValueChange={field.onChange}>
                      <FormControl>
                        <SelectTrigger className="w-full">
                          <SelectValue />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {Object.entries(documentCategoryLabels).map(
                          ([value, label]) => (
                            <SelectItem key={value} value={value}>
                              {label}
                            </SelectItem>
                          ),
                        )}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="subjectName"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Môn học (tùy chọn)</FormLabel>
                    <FormControl>
                      <Input
                        autoComplete="off"
                        placeholder="VD: Toán học"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>
          </form>
        </Form>

        <DialogFooter>
          <DialogClose asChild>
            <Button type="button" variant="outline">
              Hủy
            </Button>
          </DialogClose>
          <Button
            type="submit"
            form="upload-document-form"
            disabled={uploadMutation.isPending}
          >
            {uploadMutation.isPending ? (
              <Loader2 className="size-4 animate-spin" />
            ) : (
              <Upload className="size-4" />
            )}
            Tải lên
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

function DocumentListPanel({
  isLoading,
  page,
  result,
  deletingId,
  onDelete,
  onPageChange,
}: {
  isLoading: boolean
  page: number
  result?: {
    totalItems: number
    totalPages: number
    items: AdminDocument[]
  }
  deletingId?: string
  onDelete: (document: AdminDocument) => void
  onPageChange: (page: number) => void
}) {
  const documents = result?.items ?? []
  const columns = useMemo(
    () => documentColumns({ deletingId, onDelete }),
    [deletingId, onDelete],
  )

  return (
    <div className="flex min-h-0 min-w-0 flex-1 flex-col rounded-md border bg-background">
      <div className="min-h-0 flex-1 overflow-auto">
        <DataTable
          columns={columns}
          data={documents}
          isLoading={isLoading}
          empty={
            <Empty className="min-h-[360px] border-0">
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <FileText />
                </EmptyMedia>
                <EmptyTitle>Chưa có tài liệu</EmptyTitle>
                <EmptyDescription>
                  Bấm "Tải tài liệu" để đưa nội quy, thông tin trường hoặc tài
                  liệu môn học vào kho tri thức của trợ lý AI.
                </EmptyDescription>
              </EmptyHeader>
            </Empty>
          }
        />
      </div>

      <DataTablePagination
        page={page}
        totalPages={result?.totalPages ?? 0}
        totalItems={result?.totalItems ?? 0}
        unitLabel="tài liệu"
        onPageChange={onPageChange}
      />
    </div>
  )
}
