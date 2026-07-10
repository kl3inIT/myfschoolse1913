import { zodResolver } from '@hookform/resolvers/zod'
import {
  keepPreviousData,
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'
import { useEffect, useMemo, useState } from 'react'
import { useDropzone } from 'react-dropzone'
import { useForm, type UseFormReturn } from 'react-hook-form'
import { toast } from 'sonner'
import { z } from 'zod'
import {
  AlertCircle,
  CheckCircle2,
  Download,
  FileSpreadsheet,
  Loader2,
  Lock,
  School,
  UploadCloud,
  UserCheck,
  Users,
} from 'lucide-react'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { DataTable, DataTablePagination } from '@/components/data-table'
import { studentColumns } from './columns'
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
import { Separator } from '@/components/ui/separator'
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
import { Skeleton } from '@/components/ui/skeleton'
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
  importStudents,
  parseStudentsCsv,
  type StudentImportResponse,
  type StudentImportRow,
  type StudentImportRowResult,
} from '@/lib/student-import'
import {
  fetchStudents,
  fetchStudentStats,
  type AdminStudent,
  type AdminStudentListResponse,
  type AdminStudentStats,
} from '@/lib/students'
import { fileToCsvText, spreadsheetDropzoneAccept } from '@/lib/spreadsheet'

const pageSize = 20

const sampleCsv = `studentCode,fullName,phoneNumber,academicYearName,className,password,status
FS1913-0002,Trần Gia Hân,0900000002,Năm học 2026,Lớp 10A1,,Đang học
FS1913-0003,Lê Minh Khang,0900000003,Năm học 2026,Lớp 10A1,,Đang học`

const importDefaultsSchema = z.object({
  academicYearName: z.string().trim().min(1, 'Vui lòng nhập năm học'),
  className: z.string().trim().min(1, 'Vui lòng nhập lớp'),
  defaultPassword: z.string().min(8, 'Mật khẩu tạm thời tối thiểu 8 ký tự'),
})

type ImportDefaultsForm = z.infer<typeof importDefaultsSchema>
type DropzoneState = ReturnType<typeof useDropzone>

export function StudentManagementPage() {
  const [csvText, setCsvText] = useState(sampleCsv)
  const [fileName, setFileName] = useState('mau-hoc-sinh.csv')
  const [importOpen, setImportOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [page, setPage] = useState(0)

  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const parsed = useMemo(() => parseStudentsCsv(csvText), [csvText])

  useEffect(() => {
    const handle = setTimeout(() => {
      setDebouncedSearch(searchTerm.trim())
      setPage(0)
    }, 300)
    return () => clearTimeout(handle)
  }, [searchTerm])

  const studentsQuery = useQuery({
    queryKey: ['admin-students', 'list', debouncedSearch, page],
    queryFn: () =>
      fetchStudents({ search: debouncedSearch, page, size: pageSize }),
    placeholderData: keepPreviousData,
  })

  const statsQuery = useQuery({
    queryKey: ['admin-students', 'stats'],
    queryFn: fetchStudentStats,
  })

  const form = useForm<ImportDefaultsForm>({
    resolver: zodResolver(importDefaultsSchema),
    mode: 'onChange',
    defaultValues: {
      academicYearName: 'Năm học 2026',
      className: 'Lớp 10A1',
      defaultPassword: 'Password123',
    },
  })

  const mutation = useMutation({
    mutationFn: importStudents,
    onSuccess: (result) => {
      toast.success(
        `Đã xử lý: ${result.createdStudents} tạo mới, ${result.updatedStudents} cập nhật, ${result.skippedRows} bỏ qua`,
      )
      queryClient.invalidateQueries({ queryKey: ['admin-students'] })
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Nhập học sinh thất bại',
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

  const students = studentsQuery.data?.items ?? []

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
      toast.error('Chưa có dòng học sinh để nhập')
      return
    }

    mutation.mutate({
      ...values,
      students: parsed.rows,
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
      <StatsRow stats={statsQuery.data} isLoading={statsQuery.isPending} />

      <section className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <Input
          aria-label="Tìm học sinh"
          value={searchTerm}
          onChange={(event) => setSearchTerm(event.target.value)}
          placeholder="Tìm mã, tên, số điện thoại, lớp"
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
                Nhập CSV
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
        <StudentListPanel
          isLoading={studentsQuery.isPending}
          page={page}
          result={studentsQuery.data}
          searchTerm={searchTerm}
          students={students}
          onOpenImport={() => setImportOpen(true)}
          onPageChange={setPage}
          onSelectStudent={(student) =>
            void navigate({
              to: '/students/$studentId',
              params: { studentId: student.id },
            })
          }
        />
      </section>
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
  result?: StudentImportResponse
  onCsvTextChange: (value: string) => void
  onResetResult: () => void
  onSubmit: (values: ImportDefaultsForm) => void
  parsed: {
    rows: StudentImportRow[]
    errors: string[]
  }
}) {
  return (
    <SheetContent className="w-full overflow-y-auto p-0 sm:max-w-5xl">
      <SheetHeader className="border-b px-6 py-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div className="space-y-1">
            <SheetTitle>
              {result ? 'Kết quả nhập học sinh' : 'Nhập học sinh từ CSV'}
            </SheetTitle>
            <SheetDescription>
              {result
                ? 'Kiểm tra từng dòng đã tạo, cập nhật hoặc bị bỏ qua.'
                : 'Cấp tài khoản học sinh và gán dữ liệu vào năm học, lớp tương ứng.'}
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
            id="student-import-form"
            onSubmit={form.handleSubmit(onSubmit)}
            className="min-h-0 flex-1"
            noValidate
          >
            <div className="grid gap-6 px-6 py-5 xl:grid-cols-[minmax(0,1fr)_340px]">
              <div className="min-w-0 space-y-4">
                <div
                  {...dropzone.getRootProps({
                    className: [
                      'flex min-h-28 cursor-pointer flex-col items-center justify-center rounded-md border border-dashed p-5 text-center outline-none transition-colors',
                      'hover:bg-accent focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/40',
                      dropzone.isDragActive ? 'bg-accent' : '',
                    ].join(' '),
                  })}
                >
                  <input {...dropzone.getInputProps()} />
                  <UploadCloud className="size-7 text-muted-foreground" />
                  <p className="mt-3 text-sm font-medium">
                    Kéo CSV/Excel vào đây hoặc bấm để chọn tệp
                  </p>
                  <p className="mt-1 text-xs text-muted-foreground">
                    Cột bắt buộc: studentCode, fullName, phoneNumber
                  </p>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="csvText">Nội dung CSV</Label>
                  <Textarea
                    id="csvText"
                    value={csvText}
                    onChange={(event) => onCsvTextChange(event.target.value)}
                    className="min-h-44 resize-y font-mono text-xs leading-6 tabular-nums"
                    spellCheck={false}
                  />
                </div>

                <ImportState rows={parsed.rows} errors={parsed.errors} />
                <PreviewPanel rows={parsed.rows} />
              </div>

              <aside className="min-w-0 space-y-5">
                <div className="space-y-4">
                  <div>
                    <h3 className="text-sm font-medium">Thiết lập mặc định</h3>
                    <p className="mt-1 text-sm text-muted-foreground">
                      Dùng khi từng dòng CSV bỏ trống năm học, lớp hoặc mật khẩu.
                    </p>
                  </div>

                  <FormField
                    control={form.control}
                    name="academicYearName"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Năm học mặc định</FormLabel>
                        <FormControl>
                          <Input autoComplete="off" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="className"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Lớp mặc định</FormLabel>
                        <FormControl>
                          <Input autoComplete="off" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="defaultPassword"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Mật khẩu tạm thời</FormLabel>
                        <FormControl>
                          <Input
                            type="password"
                            autoComplete="new-password"
                            {...field}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                <Separator />
                <CsvFormatTable />
              </aside>
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
                form="student-import-form"
                disabled={!canSubmit}
              >
                {isPending ? (
                  <Loader2 className="size-4 animate-spin" />
                ) : (
                  <FileSpreadsheet className="size-4" />
                )}
                Nhập học sinh
              </Button>
            </div>
          </>
        )}
      </SheetFooter>
    </SheetContent>
  )
}

function ImportResultView({ result }: { result: StudentImportResponse }) {
  return (
    <div className="space-y-4 px-6 py-5">
      <div className="grid gap-3 sm:grid-cols-4">
        <SummaryTile label="Tài khoản mới" value={result.createdUsers} />
        <SummaryTile label="Học sinh mới" value={result.createdStudents} />
        <SummaryTile label="Đã cập nhật" value={result.updatedStudents} />
        <SummaryTile label="Bị bỏ qua" value={result.skippedRows} />
      </div>

      <div className="rounded-md border">
        <div className="max-h-[28rem] overflow-auto">
          <Table>
            <TableHeader className="sticky top-0 bg-background">
              <TableRow>
                <TableHead className="w-16">STT</TableHead>
                <TableHead>Mã học sinh</TableHead>
                <TableHead>Số điện thoại</TableHead>
                <TableHead>Kết quả</TableHead>
                <TableHead>Ghi chú</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {result.rows.map((row) => (
                <TableRow key={`${row.rowNumber}-${row.studentCode}`}>
                  <TableCell className="tabular-nums">{row.rowNumber}</TableCell>
                  <TableCell className="font-medium">
                    {row.studentCode}
                  </TableCell>
                  <TableCell className="tabular-nums">
                    {row.phoneNumber}
                  </TableCell>
                  <TableCell>
                    <ImportStatusBadge status={row.status} />
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

function StatsRow({
  stats,
  isLoading,
}: {
  stats?: AdminStudentStats
  isLoading: boolean
}) {
  const items = [
    { label: 'Tổng học sinh', value: stats?.totalStudents, icon: Users },
    { label: 'Đang học', value: stats?.activeStudents, icon: UserCheck },
    { label: 'Tài khoản khóa', value: stats?.lockedAccounts, icon: Lock },
    { label: 'Số lớp', value: stats?.totalClasses, icon: School },
  ]

  return (
    <section className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
      {items.map((item) => (
        <div
          key={item.label}
          className="flex items-center gap-3 rounded-md border bg-background p-4"
        >
          <div className="flex size-9 shrink-0 items-center justify-center rounded-md bg-muted">
            <item.icon className="size-4 text-muted-foreground" />
          </div>
          <div className="min-w-0">
            <p className="text-xs text-muted-foreground">{item.label}</p>
            {isLoading ? (
              <Skeleton className="mt-1 h-6 w-12" />
            ) : (
              <p className="text-xl font-semibold tabular-nums">
                {item.value ?? 0}
              </p>
            )}
          </div>
        </div>
      ))}
    </section>
  )
}

function StudentListPanel({
  isLoading,
  page,
  result,
  searchTerm,
  students,
  onOpenImport,
  onPageChange,
  onSelectStudent,
}: {
  isLoading: boolean
  page: number
  result?: AdminStudentListResponse
  searchTerm: string
  students: AdminStudent[]
  onOpenImport: () => void
  onPageChange: (page: number) => void
  onSelectStudent: (student: AdminStudent) => void
}) {
  return (
    <div className="flex min-h-0 min-w-0 flex-1 flex-col rounded-md border bg-background">
      <div className="min-h-0 flex-1 overflow-auto">
        <DataTable
          columns={studentColumns}
          data={students}
          isLoading={isLoading}
          onRowClick={onSelectStudent}
          empty={
            <Empty className="min-h-[360px] border-0">
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <Users />
                </EmptyMedia>
                <EmptyTitle>
                  {searchTerm
                    ? 'Không tìm thấy học sinh'
                    : 'Chưa có dữ liệu học sinh'}
                </EmptyTitle>
                <EmptyDescription>
                  {searchTerm
                    ? 'Thử từ khóa khác hoặc xóa ô tìm kiếm.'
                    : 'Nhập CSV để cấp tài khoản học sinh đầu tiên.'}
                </EmptyDescription>
              </EmptyHeader>
              {searchTerm ? null : (
                <Button type="button" variant="outline" onClick={onOpenImport}>
                  <UploadCloud className="size-4" />
                  Nhập CSV
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
        unitLabel="học sinh"
        onPageChange={onPageChange}
      />
    </div>
  )
}

function ImportState({
  rows,
  errors,
}: {
  rows: StudentImportRow[]
  errors: string[]
}) {
  if (errors.length > 0) {
    return (
      <Alert variant="destructive">
        <AlertCircle />
        <AlertTitle>CSV chưa hợp lệ</AlertTitle>
        <AlertDescription>{errors[0]}</AlertDescription>
      </Alert>
    )
  }

  if (rows.length === 0) {
    return (
      <Alert>
        <FileSpreadsheet />
        <AlertTitle>Chưa có dòng dữ liệu</AlertTitle>
        <AlertDescription>
          Dán CSV hoặc chọn tệp có đủ các cột bắt buộc.
        </AlertDescription>
      </Alert>
    )
  }

  return (
    <Alert>
      <CheckCircle2 />
      <AlertTitle>CSV hợp lệ</AlertTitle>
      <AlertDescription>
        Đọc được {rows.length} dòng học sinh sẵn sàng nhập.
      </AlertDescription>
    </Alert>
  )
}

function PreviewPanel({ rows }: { rows: StudentImportRow[] }) {
  return (
    <div className="rounded-md border">
      <div className="flex flex-col gap-2 border-b px-3 py-2 sm:flex-row sm:items-center sm:justify-between">
        <h3 className="text-sm font-medium">Kiểm tra dữ liệu</h3>
        <span className="text-sm text-muted-foreground">
          {rows.length} dòng hợp lệ
        </span>
      </div>
      {rows.length > 0 ? (
        <div className="max-h-72 overflow-auto">
          <Table>
            <TableHeader className="sticky top-0 bg-background">
              <TableRow>
                <TableHead>STT</TableHead>
                <TableHead>Mã học sinh</TableHead>
                <TableHead>Họ và tên</TableHead>
                <TableHead>Số điện thoại</TableHead>
                <TableHead>Năm học</TableHead>
                <TableHead>Lớp</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {rows.map((row, index) => (
                <TableRow key={`${row.studentCode}-${row.phoneNumber}`}>
                  <TableCell className="tabular-nums">{index + 1}</TableCell>
                  <TableCell className="font-medium">{row.studentCode}</TableCell>
                  <TableCell>{row.fullName}</TableCell>
                  <TableCell className="tabular-nums">{row.phoneNumber}</TableCell>
                  <TableCell>{row.academicYearName ?? 'Dùng mặc định'}</TableCell>
                  <TableCell>{row.className ?? 'Dùng mặc định'}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      ) : (
        <Empty className="min-h-40 border-0">
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <FileSpreadsheet />
            </EmptyMedia>
            <EmptyTitle>Chưa có dữ liệu hợp lệ</EmptyTitle>
            <EmptyDescription>
              Dữ liệu xem trước sẽ xuất hiện sau khi CSV hợp lệ.
            </EmptyDescription>
          </EmptyHeader>
        </Empty>
      )}
    </div>
  )
}

function CsvFormatTable() {
  return (
    <div className="space-y-2">
      <h3 className="text-sm font-medium">Định dạng CSV</h3>
      <div className="rounded-md border">
        <Table>
          <TableBody>
            <FormatRow label="studentCode" value="Bắt buộc, duy nhất" />
            <FormatRow label="fullName" value="Bắt buộc" />
            <FormatRow label="phoneNumber" value="Bắt buộc, dùng đăng nhập" />
            <FormatRow label="academicYearName" value="Tùy chọn" />
            <FormatRow label="className" value="Tùy chọn" />
            <FormatRow label="password" value="Tùy chọn" />
            <FormatRow label="status" value="Tùy chọn" />
          </TableBody>
        </Table>
      </div>
    </div>
  )
}

function FormatRow({ label, value }: { label: string; value: string }) {
  return (
    <TableRow>
      <TableCell className="whitespace-normal font-mono text-xs font-semibold">
        {label}
      </TableCell>
      <TableCell className="whitespace-normal text-muted-foreground">
        {value}
      </TableCell>
    </TableRow>
  )
}

function ImportStatusBadge({
  status,
}: {
  status: StudentImportRowResult['status']
}) {
  if (status === 'CREATED') {
    return <Badge>Tạo mới</Badge>
  }
  if (status === 'UPDATED') {
    return <Badge variant="secondary">Cập nhật</Badge>
  }
  return <Badge variant="outline">Bỏ qua</Badge>
}

function downloadTemplate() {
  const blob = new Blob([sampleCsv], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = url
  anchor.download = 'mau-nhap-hoc-sinh.csv'
  anchor.click()
  URL.revokeObjectURL(url)
}
