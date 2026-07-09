import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation } from '@tanstack/react-query'
import { useMemo, useState } from 'react'
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
  UploadCloud,
  Users,
} from 'lucide-react'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
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
  const [selectedRowKey, setSelectedRowKey] = useState<string>()

  const parsed = useMemo(() => parseStudentsCsv(csvText), [csvText])

  const form = useForm<ImportDefaultsForm>({
    resolver: zodResolver(importDefaultsSchema),
    mode: 'onChange',
    defaultValues: {
      academicYearName: 'Năm học 2026',
      className: 'Lớp 10A1',
      defaultPassword: 'Password123',
    },
  })

  const mutation = useMutationImport({
    onSuccess: (result) => {
      setSelectedRowKey(result.rows[0] ? importResultKey(result.rows[0]) : undefined)
      setImportOpen(false)
    },
  })

  const dropzone = useDropzone({
    multiple: false,
    accept: {
      'text/csv': ['.csv'],
      'text/plain': ['.csv'],
      'application/vnd.ms-excel': ['.csv'],
    },
    onDrop: async (acceptedFiles) => {
      const file = acceptedFiles[0]
      if (!file) {
        return
      }

      setCsvText(await file.text())
      setFileName(file.name)
      toast.success(`Đã nạp tệp ${file.name}`)
    },
    onDropRejected: (rejections) => {
      toast.error(
        rejections[0]?.errors[0]?.message ?? 'Tệp CSV không hợp lệ',
      )
    },
  })

  const visibleRows = useMemo(() => {
    const rows = mutation.data?.rows ?? []
    const query = searchTerm.trim().toLowerCase()

    if (!query) {
      return rows
    }

    return rows.filter((row) =>
      [
        row.studentCode,
        row.phoneNumber,
        row.message,
        importStatusLabel(row.status),
      ].some((value) => value.toLowerCase().includes(query)),
    )
  }, [mutation.data, searchTerm])

  const selectedRow = useMemo(() => {
    const rows = mutation.data?.rows ?? []
    return (
      rows.find((row) => importResultKey(row) === selectedRowKey) ?? rows[0]
    )
  }, [mutation.data, selectedRowKey])

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

  return (
    <div className="flex min-h-[calc(100vh-8rem)] flex-col gap-4">
      <section className="flex flex-col gap-3 border-b pb-4 lg:flex-row lg:items-end lg:justify-between">
        <div className="min-w-0 space-y-1">
          <h2 className="text-lg font-semibold tracking-tight">
            Danh sách học sinh
          </h2>
          <p className="max-w-2xl text-sm text-muted-foreground">
            Quản lý hồ sơ, tài khoản đăng nhập và lớp học của học sinh.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <Button type="button" variant="outline" onClick={downloadTemplate}>
            <Download className="size-4" />
            Tải mẫu CSV
          </Button>
          <Sheet open={importOpen} onOpenChange={setImportOpen}>
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
              onCsvTextChange={updateCsvText}
              onSubmit={submit}
              parsed={parsed}
            />
          </Sheet>
        </div>
      </section>

      <section className="grid min-h-0 flex-1 gap-4 xl:grid-cols-[minmax(0,1fr)_360px]">
        <StudentListPanel
          result={mutation.data}
          rows={visibleRows}
          searchTerm={searchTerm}
          selectedRowKey={selectedRow ? importResultKey(selectedRow) : undefined}
          onOpenImport={() => setImportOpen(true)}
          onSearchTermChange={setSearchTerm}
          onSelectRow={(row) => setSelectedRowKey(importResultKey(row))}
        />
        <StudentDetailPanel result={mutation.data} row={selectedRow} />
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
  onCsvTextChange,
  onSubmit,
  parsed,
}: {
  canSubmit: boolean
  csvText: string
  dropzone: DropzoneState
  fileName: string
  form: UseFormReturn<ImportDefaultsForm>
  isPending: boolean
  onCsvTextChange: (value: string) => void
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
            <SheetTitle>Nhập học sinh từ CSV</SheetTitle>
            <SheetDescription>
              Cấp tài khoản học sinh và gán dữ liệu vào năm học, lớp tương ứng.
            </SheetDescription>
          </div>
          <p className="text-sm text-muted-foreground">
            {fileName}
          </p>
        </div>
      </SheetHeader>

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
                  Kéo CSV vào đây hoặc bấm để chọn tệp
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

      <SheetFooter className="border-t px-6 py-4 sm:flex-row sm:items-center sm:justify-between">
        <p className="text-xs text-muted-foreground">
          Tối đa 500 dòng cho mỗi lần nhập.
        </p>
        <div className="flex flex-col-reverse gap-2 sm:flex-row">
          <SheetClose asChild>
            <Button type="button" variant="outline">
              Hủy
            </Button>
          </SheetClose>
          <Button type="submit" form="student-import-form" disabled={!canSubmit}>
            {isPending ? (
              <Loader2 className="size-4 animate-spin" />
            ) : (
              <FileSpreadsheet className="size-4" />
            )}
            Nhập học sinh
          </Button>
        </div>
      </SheetFooter>
    </SheetContent>
  )
}

function StudentListPanel({
  result,
  rows,
  searchTerm,
  selectedRowKey,
  onOpenImport,
  onSearchTermChange,
  onSelectRow,
}: {
  result?: StudentImportResponse
  rows: StudentImportRowResult[]
  searchTerm: string
  selectedRowKey?: string
  onOpenImport: () => void
  onSearchTermChange: (value: string) => void
  onSelectRow: (row: StudentImportRowResult) => void
}) {
  return (
    <div className="flex min-h-[520px] min-w-0 flex-col rounded-md border bg-background">
      <div className="flex flex-col gap-3 border-b p-3 lg:flex-row lg:items-center lg:justify-between">
        <div className="min-w-0">
          <h3 className="text-sm font-semibold">Danh sách học sinh</h3>
          <p className="text-sm text-muted-foreground">
            {result
              ? 'Đang hiển thị kết quả nhập gần nhất.'
              : 'Danh sách sẽ kết nối API học sinh ở bước tiếp theo.'}
          </p>
        </div>
        <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
          <Input
            aria-label="Tìm học sinh"
            value={searchTerm}
            onChange={(event) => onSearchTermChange(event.target.value)}
            placeholder="Tìm mã, số điện thoại, ghi chú"
            className="sm:w-72"
          />
          <Button type="button" variant="outline" onClick={onOpenImport}>
            <UploadCloud className="size-4" />
            Nhập CSV
          </Button>
        </div>
      </div>

      <div className="min-h-0 flex-1 overflow-auto">
        {result ? (
          <Table>
            <TableHeader className="sticky top-0 bg-background">
              <TableRow>
                <TableHead className="w-16">STT</TableHead>
                <TableHead>Mã học sinh</TableHead>
                <TableHead>Số điện thoại</TableHead>
                <TableHead>Trạng thái</TableHead>
                <TableHead>Ghi chú</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {rows.map((row) => {
                const key = importResultKey(row)
                return (
                  <TableRow
                    key={key}
                    data-state={key === selectedRowKey ? 'selected' : undefined}
                    tabIndex={0}
                    className="cursor-pointer"
                    onClick={() => onSelectRow(row)}
                    onKeyDown={(event) => {
                      if (event.key === 'Enter' || event.key === ' ') {
                        onSelectRow(row)
                      }
                    }}
                  >
                    <TableCell className="tabular-nums">
                      {row.rowNumber}
                    </TableCell>
                    <TableCell className="font-medium">
                      {row.studentCode}
                    </TableCell>
                    <TableCell className="tabular-nums">
                      {row.phoneNumber}
                    </TableCell>
                    <TableCell>
                      <StatusBadge row={row} />
                    </TableCell>
                    <TableCell className="max-w-md truncate text-muted-foreground">
                      {row.message}
                    </TableCell>
                  </TableRow>
                )
              })}
            </TableBody>
          </Table>
        ) : (
          <Empty className="min-h-[360px] border-0">
            <EmptyHeader>
              <EmptyMedia variant="icon">
                <Users />
              </EmptyMedia>
              <EmptyTitle>Chưa có dữ liệu học sinh</EmptyTitle>
              <EmptyDescription>
                Nhập CSV để cấp tài khoản học sinh trước khi mở rộng API danh
                sách.
              </EmptyDescription>
            </EmptyHeader>
          </Empty>
        )}
      </div>

      <div className="flex items-center justify-between border-t px-3 py-2 text-xs text-muted-foreground">
        <span>{result ? `${rows.length}/${result.totalRows} dòng` : '0 dòng'}</span>
        <span>{result ? 'Kết quả nhập gần nhất' : 'Chưa có lần nhập'}</span>
      </div>
    </div>
  )
}

function StudentDetailPanel({
  result,
  row,
}: {
  result?: StudentImportResponse
  row?: StudentImportRowResult
}) {
  return (
    <aside className="flex min-h-[520px] min-w-0 flex-col rounded-md border bg-background">
      <div className="border-b p-4">
        <h3 className="text-sm font-semibold">Chi tiết học sinh</h3>
        <p className="text-sm text-muted-foreground">
          Thông tin của dòng đang chọn trong danh sách.
        </p>
      </div>

      {row ? (
        <div className="min-h-0 flex-1 space-y-5 overflow-auto p-4">
          <div className="space-y-3">
            <DetailRow label="Mã học sinh" value={row.studentCode} />
            <DetailRow label="Số điện thoại" value={row.phoneNumber} />
            <DetailRow label="Trạng thái" value={importStatusLabel(row.status)} />
            <DetailRow label="Ghi chú" value={row.message} />
          </div>

          {result ? (
            <>
              <Separator />
              <div className="space-y-2">
                <h4 className="text-sm font-medium">Tổng hợp lần nhập</h4>
                <ResultSummary result={result} />
              </div>
            </>
          ) : null}
        </div>
      ) : (
        <Empty className="min-h-[360px] border-0">
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <Users />
            </EmptyMedia>
            <EmptyTitle>Chưa chọn học sinh</EmptyTitle>
            <EmptyDescription>
              Chọn một dòng trong danh sách để xem chi tiết.
            </EmptyDescription>
          </EmptyHeader>
        </Empty>
      )}
    </aside>
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

function ResultSummary({ result }: { result: StudentImportResponse }) {
  return (
    <div className="rounded-md border">
      <Table>
        <TableBody>
          <SummaryRow label="Tài khoản mới" value={result.createdUsers} />
          <SummaryRow label="Học sinh mới" value={result.createdStudents} />
          <SummaryRow label="Đã cập nhật" value={result.updatedStudents} />
          <SummaryRow label="Bị bỏ qua" value={result.skippedRows} />
        </TableBody>
      </Table>
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

function DetailRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="space-y-1">
      <p className="text-xs font-medium uppercase text-muted-foreground">
        {label}
      </p>
      <p className="break-words text-sm">{value}</p>
    </div>
  )
}

function SummaryRow({ label, value }: { label: string; value: number }) {
  return (
    <TableRow>
      <TableCell className="text-muted-foreground">{label}</TableCell>
      <TableCell className="text-right font-semibold tabular-nums">
        {value}
      </TableCell>
    </TableRow>
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

function StatusBadge({ row }: { row: StudentImportRowResult }) {
  if (row.status === 'CREATED') {
    return <Badge>Tạo mới</Badge>
  }
  if (row.status === 'UPDATED') {
    return <Badge variant="secondary">Cập nhật</Badge>
  }
  return <Badge variant="outline">Bỏ qua</Badge>
}

function useMutationImport({
  onSuccess,
}: {
  onSuccess?: (result: StudentImportResponse) => void
} = {}) {
  return useMutation({
    mutationFn: importStudents,
    onSuccess: (result) => {
      toast.success(
        `Đã xử lý: ${result.createdStudents} tạo mới, ${result.updatedStudents} cập nhật`,
      )
      onSuccess?.(result)
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Nhập học sinh thất bại',
      )
    },
  })
}

function importResultKey(row: StudentImportRowResult) {
  return `${row.rowNumber}-${row.studentCode}-${row.phoneNumber}`
}

function importStatusLabel(status: StudentImportRowResult['status']) {
  if (status === 'CREATED') {
    return 'Tạo mới'
  }
  if (status === 'UPDATED') {
    return 'Cập nhật'
  }
  return 'Bỏ qua'
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
