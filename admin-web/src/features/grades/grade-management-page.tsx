import { zodResolver } from '@hookform/resolvers/zod'
import {
  keepPreviousData,
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import { useEffect, useMemo, useState } from 'react'
import { useDropzone } from 'react-dropzone'
import { useForm, type UseFormReturn } from 'react-hook-form'
import { toast } from 'sonner'
import { z } from 'zod'
import {
  AlertCircle,
  BookOpenCheck,
  CheckCircle2,
  Download,
  FileSpreadsheet,
  Loader2,
  UploadCloud,
} from 'lucide-react'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { DataTable, DataTablePagination } from '@/components/data-table'
import { gradeColumns } from './columns'
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
import { Label } from '@/components/ui/label'
import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from '@/components/ui/sheet'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Textarea } from '@/components/ui/textarea'
import {
  fetchGrades,
  importGrades,
  parseGradesCsv,
  type AdminGrade,
  type AdminGradeListResponse,
  type GradeImportResponse,
  type GradeImportRow,
  type GradeImportRowResult,
} from '@/lib/grades'
import { fileToCsvText, spreadsheetDropzoneAccept } from '@/lib/spreadsheet'

const pageSize = 20

const sampleCsv = `studentCode,subjectCode,subjectName,formativeScore,midtermScore,finalScore,averageScore,teacherComment
FS1913-0001,MATH,Toán học,8.5,8,9,,Tiến bộ rõ ở hình học
FS1913-0001,ENGLISH,Tiếng Anh,7.5,8,7.5,,`

const importDefaultsSchema = z.object({
  academicYearName: z.string().trim().min(1, 'Vui lòng nhập năm học'),
  semesterName: z.string().trim().min(1, 'Vui lòng nhập học kỳ'),
})

type ImportDefaultsForm = z.infer<typeof importDefaultsSchema>
type DropzoneState = ReturnType<typeof useDropzone>

export function GradeManagementPage() {
  const [csvText, setCsvText] = useState(sampleCsv)
  const [fileName, setFileName] = useState('mau-diem.csv')
  const [importOpen, setImportOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [page, setPage] = useState(0)

  const queryClient = useQueryClient()
  const parsed = useMemo(() => parseGradesCsv(csvText), [csvText])

  useEffect(() => {
    const handle = setTimeout(() => {
      setDebouncedSearch(searchTerm.trim())
      setPage(0)
    }, 300)
    return () => clearTimeout(handle)
  }, [searchTerm])

  const gradesQuery = useQuery({
    queryKey: ['admin-grades', 'list', debouncedSearch, page],
    queryFn: () =>
      fetchGrades({ search: debouncedSearch, page, size: pageSize }),
    placeholderData: keepPreviousData,
  })

  const form = useForm<ImportDefaultsForm>({
    resolver: zodResolver(importDefaultsSchema),
    mode: 'onChange',
    defaultValues: {
      academicYearName: 'Năm học 2026',
      semesterName: 'Học kỳ 1',
    },
  })

  const mutation = useMutation({
    mutationFn: importGrades,
    onSuccess: (result) => {
      toast.success(
        `Đã xử lý: ${result.createdGrades} ghi mới, ${result.updatedGrades} cập nhật, ${result.skippedRows} bỏ qua`,
      )
      queryClient.invalidateQueries({ queryKey: ['admin-grades'] })
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Nhập điểm thất bại',
      )
    },
  })

  const dropzone = useDropzone({
    multiple: false,
    accept: spreadsheetDropzoneAccept,
    onDrop: async (acceptedFiles) => {
      const file = acceptedFiles[0]
      if (!file) {
        return
      }

      try {
        setCsvText(await fileToCsvText(file))
      } catch (error) {
        toast.error(
          error instanceof Error ? error.message : 'Không đọc được tệp',
        )
        return
      }
      setFileName(file.name)
      toast.success(`Đã nạp tệp ${file.name}`)
    },
    onDropRejected: (rejections) => {
      toast.error(
        rejections[0]?.errors[0]?.message ?? 'Tệp CSV/Excel không hợp lệ',
      )
    },
  })

  const grades = gradesQuery.data?.items ?? []

  const defaultsValid = importDefaultsSchema.safeParse(form.watch()).success
  const canSubmit =
    defaultsValid &&
    parsed.rows.length > 0 &&
    parsed.errors.length === 0 &&
    !mutation.isPending

  function updateCsvText(value: string) {
    setCsvText(value)
    setFileName('nhap-thu-cong.csv')
  }

  function submit(values: ImportDefaultsForm) {
    if (parsed.errors.length > 0) {
      toast.error(parsed.errors[0])
      return
    }
    if (parsed.rows.length === 0) {
      toast.error('Chưa có dòng điểm để nhập')
      return
    }

    mutation.mutate({
      ...values,
      grades: parsed.rows,
    })
  }

  function changeImportOpen(open: boolean) {
    setImportOpen(open)
    if (!open) {
      mutation.reset()
    }
  }

  return (
    <div className="flex h-[calc(100svh-8rem)] flex-col gap-4">
      <section className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <Input
          aria-label="Tìm điểm"
          value={searchTerm}
          onChange={(event) => setSearchTerm(event.target.value)}
          placeholder="Tìm mã, tên học sinh, lớp, môn"
          className="sm:w-72"
        />

        <div className="flex flex-wrap items-center gap-2">
          <Button type="button" variant="outline" onClick={downloadTemplate}>
            <Download className="size-4" />
            Tải mẫu CSV
          </Button>
          <Sheet open={importOpen} onOpenChange={changeImportOpen}>
            <SheetTrigger asChild>
              <Button type="button">
                <UploadCloud className="size-4" />
                Nhập điểm
              </Button>
            </SheetTrigger>
            <ImportSheetContent
              canSubmit={canSubmit}
              csvText={csvText}
              dropzone={dropzone}
              fileName={fileName}
              form={form}
              isPending={mutation.isPending}
              result={mutation.data}
              onCsvTextChange={updateCsvText}
              onResetResult={() => mutation.reset()}
              onSubmit={submit}
              parsed={parsed}
            />
          </Sheet>
        </div>
      </section>

      <section className="flex min-h-0 flex-1 flex-col">
        <GradeListPanel
          isLoading={gradesQuery.isPending}
          page={page}
          result={gradesQuery.data}
          searchTerm={searchTerm}
          grades={grades}
          onOpenImport={() => setImportOpen(true)}
          onPageChange={setPage}
        />
      </section>
    </div>
  )
}

function GradeListPanel({
  isLoading,
  page,
  result,
  searchTerm,
  grades,
  onOpenImport,
  onPageChange,
}: {
  isLoading: boolean
  page: number
  result?: AdminGradeListResponse
  searchTerm: string
  grades: AdminGrade[]
  onOpenImport: () => void
  onPageChange: (page: number) => void
}) {
  return (
    <div className="flex min-h-0 min-w-0 flex-1 flex-col rounded-md border bg-background">
      <div className="min-h-0 flex-1 overflow-auto">
        <DataTable
          columns={gradeColumns}
          data={grades}
          isLoading={isLoading}
          empty={
            <Empty className="min-h-[360px] border-0">
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <BookOpenCheck />
                </EmptyMedia>
                <EmptyTitle>
                  {searchTerm
                    ? 'Không tìm thấy dòng điểm'
                    : 'Chưa có dữ liệu điểm'}
                </EmptyTitle>
                <EmptyDescription>
                  {searchTerm
                    ? 'Thử từ khóa khác hoặc xóa ô tìm kiếm.'
                    : 'Nhập CSV/Excel để ghi điểm học kỳ đầu tiên.'}
                </EmptyDescription>
              </EmptyHeader>
              {searchTerm ? null : (
                <Button type="button" variant="outline" onClick={onOpenImport}>
                  <UploadCloud className="size-4" />
                  Nhập điểm
                </Button>
              )}
            </Empty>
          }
        />
      </div>

      <DataTablePagination
        page={page}
        totalPages={result?.totalPages ?? 0}
        totalItems={result?.totalItems ?? 0}
        unitLabel="dòng điểm"
        onPageChange={onPageChange}
      />
    </div>
  )
}

function ImportSheetContent({
  canSubmit,
  csvText,
  dropzone,
  fileName,
  form,
  isPending,
  result,
  onCsvTextChange,
  onResetResult,
  onSubmit,
  parsed,
}: {
  canSubmit: boolean
  csvText: string
  dropzone: DropzoneState
  fileName: string
  form: UseFormReturn<ImportDefaultsForm>
  isPending: boolean
  result?: GradeImportResponse
  onCsvTextChange: (value: string) => void
  onResetResult: () => void
  onSubmit: (values: ImportDefaultsForm) => void
  parsed: {
    rows: GradeImportRow[]
    errors: string[]
  }
}) {
  return (
    <SheetContent className="w-full overflow-y-auto p-0 sm:max-w-4xl">
      <SheetHeader className="border-b px-6 py-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div className="space-y-1">
            <SheetTitle>
              {result ? 'Kết quả nhập điểm' : 'Nhập điểm từ CSV/Excel'}
            </SheetTitle>
            <SheetDescription>
              {result
                ? 'Kiểm tra từng dòng đã ghi mới, cập nhật hoặc bị bỏ qua.'
                : 'Cột bắt buộc: studentCode, subjectCode. Bỏ trống averageScore để hệ thống tự tính (TX ×1, GK ×2, CK ×3).'}
            </SheetDescription>
          </div>
          {result ? null : (
            <p className="text-sm text-muted-foreground">{fileName}</p>
          )}
        </div>
      </SheetHeader>

      {result ? (
        <ImportResultView result={result} />
      ) : (
        <Form {...form}>
          <form
            id="grade-import-form"
            onSubmit={form.handleSubmit(onSubmit)}
            className="min-h-0 flex-1"
            noValidate
          >
            <div className="space-y-4 px-6 py-5">
              <div className="grid gap-4 sm:grid-cols-2">
                <FormField
                  control={form.control}
                  name="academicYearName"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Năm học</FormLabel>
                      <FormControl>
                        <Input autoComplete="off" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="semesterName"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Học kỳ</FormLabel>
                      <FormControl>
                        <Input autoComplete="off" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <div
                {...dropzone.getRootProps({
                  className: [
                    'flex min-h-24 cursor-pointer flex-col items-center justify-center rounded-md border border-dashed p-4 text-center outline-none transition-colors',
                    'hover:bg-accent focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/40',
                    dropzone.isDragActive ? 'bg-accent' : '',
                  ].join(' '),
                })}
              >
                <input {...dropzone.getInputProps()} />
                <UploadCloud className="size-6 text-muted-foreground" />
                <p className="mt-2 text-sm font-medium">
                  Kéo CSV/Excel vào đây hoặc bấm để chọn tệp
                </p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="gradesCsv">Nội dung CSV</Label>
                <Textarea
                  id="gradesCsv"
                  value={csvText}
                  onChange={(event) => onCsvTextChange(event.target.value)}
                  className="min-h-36 resize-y font-mono text-xs leading-6 tabular-nums"
                  spellCheck={false}
                />
              </div>

              {parsed.errors.length > 0 ? (
                <Alert variant="destructive">
                  <AlertCircle />
                  <AlertTitle>CSV chưa hợp lệ</AlertTitle>
                  <AlertDescription>{parsed.errors[0]}</AlertDescription>
                </Alert>
              ) : parsed.rows.length > 0 ? (
                <Alert>
                  <CheckCircle2 />
                  <AlertTitle>CSV hợp lệ</AlertTitle>
                  <AlertDescription>
                    Đọc được {parsed.rows.length} dòng điểm sẵn sàng nhập.
                  </AlertDescription>
                </Alert>
              ) : (
                <Alert>
                  <FileSpreadsheet />
                  <AlertTitle>Chưa có dòng dữ liệu</AlertTitle>
                  <AlertDescription>
                    Dán CSV hoặc chọn tệp có đủ cột studentCode và subjectCode.
                  </AlertDescription>
                </Alert>
              )}

              <PreviewTable rows={parsed.rows} />
            </div>
          </form>
        </Form>
      )}

      <SheetFooter className="border-t px-6 py-4 sm:flex-row sm:items-center sm:justify-between">
        {result ? (
          <>
            <p className="text-xs text-muted-foreground">
              {result.totalRows} dòng đã xử lý.
            </p>
            <div className="flex flex-col-reverse gap-2 sm:flex-row">
              <Button type="button" variant="outline" onClick={onResetResult}>
                Nhập lần khác
              </Button>
              <SheetClose asChild>
                <Button type="button">Đóng</Button>
              </SheetClose>
            </div>
          </>
        ) : (
          <>
            <p className="text-xs text-muted-foreground">
              Tối đa 500 dòng cho mỗi lần nhập.
            </p>
            <div className="flex flex-col-reverse gap-2 sm:flex-row">
              <SheetClose asChild>
                <Button type="button" variant="outline">
                  Hủy
                </Button>
              </SheetClose>
              <Button
                type="submit"
                form="grade-import-form"
                disabled={!canSubmit}
              >
                {isPending ? (
                  <Loader2 className="size-4 animate-spin" />
                ) : (
                  <FileSpreadsheet className="size-4" />
                )}
                Nhập điểm
              </Button>
            </div>
          </>
        )}
      </SheetFooter>
    </SheetContent>
  )
}

function PreviewTable({ rows }: { rows: GradeImportRow[] }) {
  if (rows.length === 0) {
    return null
  }

  return (
    <div className="rounded-md border">
      <div className="flex items-center justify-between border-b px-3 py-2">
        <h3 className="text-sm font-medium">Kiểm tra dữ liệu</h3>
        <span className="text-sm text-muted-foreground">
          {rows.length} dòng hợp lệ
        </span>
      </div>
      <div className="max-h-64 overflow-auto">
        <Table>
          <TableHeader className="sticky top-0 bg-background">
            <TableRow>
              <TableHead>Mã học sinh</TableHead>
              <TableHead>Môn</TableHead>
              <TableHead className="text-right">TX</TableHead>
              <TableHead className="text-right">GK</TableHead>
              <TableHead className="text-right">CK</TableHead>
              <TableHead className="text-right">TB</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {rows.map((row, index) => (
              <TableRow key={`${row.studentCode}-${row.subjectCode}-${index}`}>
                <TableCell className="font-medium">{row.studentCode}</TableCell>
                <TableCell>{row.subjectName ?? row.subjectCode}</TableCell>
                <TableCell className="text-right tabular-nums">
                  {formatScore(row.formativeScore)}
                </TableCell>
                <TableCell className="text-right tabular-nums">
                  {formatScore(row.midtermScore)}
                </TableCell>
                <TableCell className="text-right tabular-nums">
                  {formatScore(row.finalScore)}
                </TableCell>
                <TableCell className="text-right tabular-nums">
                  {row.averageScore != null
                    ? formatScore(row.averageScore)
                    : 'Tự tính'}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}

function ImportResultView({ result }: { result: GradeImportResponse }) {
  return (
    <div className="space-y-4 px-6 py-5">
      <div className="grid gap-3 sm:grid-cols-3">
        <SummaryTile label="Ghi mới" value={result.createdGrades} />
        <SummaryTile label="Đã cập nhật" value={result.updatedGrades} />
        <SummaryTile label="Bị bỏ qua" value={result.skippedRows} />
      </div>

      <div className="rounded-md border">
        <div className="max-h-[28rem] overflow-auto">
          <Table>
            <TableHeader className="sticky top-0 bg-background">
              <TableRow>
                <TableHead className="w-16">STT</TableHead>
                <TableHead>Mã học sinh</TableHead>
                <TableHead>Mã môn</TableHead>
                <TableHead>Kết quả</TableHead>
                <TableHead>Ghi chú</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {result.rows.map((row) => (
                <TableRow
                  key={`${row.rowNumber}-${row.studentCode}-${row.subjectCode}`}
                >
                  <TableCell className="tabular-nums">
                    {row.rowNumber}
                  </TableCell>
                  <TableCell className="font-medium">
                    {row.studentCode}
                  </TableCell>
                  <TableCell>{row.subjectCode}</TableCell>
                  <TableCell>
                    <GradeStatusBadge status={row.status} />
                  </TableCell>
                  <TableCell className="max-w-md truncate text-muted-foreground">
                    {row.message}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </div>
    </div>
  )
}

function SummaryTile({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-md border p-3">
      <p className="text-xs text-muted-foreground">{label}</p>
      <p className="mt-1 text-xl font-semibold tabular-nums">{value}</p>
    </div>
  )
}

function GradeStatusBadge({
  status,
}: {
  status: GradeImportRowResult['status']
}) {
  if (status === 'CREATED') {
    return <Badge>Ghi mới</Badge>
  }
  if (status === 'UPDATED') {
    return <Badge variant="secondary">Cập nhật</Badge>
  }
  return <Badge variant="outline">Bỏ qua</Badge>
}

function formatScore(value?: number) {
  return value != null ? value.toString() : '—'
}

function downloadTemplate() {
  const blob = new Blob([sampleCsv], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = url
  anchor.download = 'mau-nhap-diem.csv'
  anchor.click()
  URL.revokeObjectURL(url)
}
