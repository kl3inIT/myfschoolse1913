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
  CalendarDays,
  CheckCircle2,
  Download,
  FileSpreadsheet,
  LayoutGrid,
  List,
  Loader2,
  UploadCloud,
} from 'lucide-react'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { DataTable, DataTablePagination } from '@/components/data-table'
import { timetableColumns } from './columns'
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
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
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
  dayIndexLabels,
  fetchTimetable,
  importTimetable,
  parseTimetableCsv,
  type AdminTimetableListResponse,
  type AdminTimetableSlot,
  type TimetableImportResponse,
  type TimetableImportRow,
  type TimetableImportRowResult,
} from '@/lib/timetable'
import { fetchAcademicYears } from '@/lib/academic-years'
import { fileToCsvText, spreadsheetDropzoneAccept } from '@/lib/spreadsheet'
import { cn } from '@/lib/utils'
import { TimetableWeeklyGrid } from './weekly-grid'

const pageSize = 20

const sampleCsv = `className,dayIndex,lessonNumber,subjectCode,subjectName,title,slotType,roomName,teacherName,startsAt,endsAt
Lớp 10A1,5,1,MATH,Toán học,,SUBJECT,Phòng 10A1,Cô Lan,07:45,08:30
Lớp 10A1,5,2,LITERATURE,Ngữ văn,,SUBJECT,Phòng 10A1,Cô Mai,08:40,09:25
Lớp 10A1,5,5,,,Ăn trưa / nghỉ trưa,MEAL,Nhà ăn,,11:20,13:30`

const importDefaultsSchema = z.object({
  academicYearName: z.string().trim().min(1, 'Vui lòng nhập năm học'),
  semesterName: z.string().trim().min(1, 'Vui lòng nhập học kỳ'),
  defaultClassName: z.string().trim(),
})

type ImportDefaultsForm = z.infer<typeof importDefaultsSchema>
type DropzoneState = ReturnType<typeof useDropzone>

type TimetableView = 'list' | 'grid'

export function TimetableManagementPage() {
  const [csvText, setCsvText] = useState(sampleCsv)
  const [fileName, setFileName] = useState('mau-tkb.csv')
  const [importOpen, setImportOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [page, setPage] = useState(0)
  const [view, setView] = useState<TimetableView>('list')
  const [selectedClassKey, setSelectedClassKey] = useState('')
  const [selectedSemester, setSelectedSemester] = useState('')

  const queryClient = useQueryClient()
  const parsed = useMemo(() => parseTimetableCsv(csvText), [csvText])

  useEffect(() => {
    const handle = setTimeout(() => {
      setDebouncedSearch(searchTerm.trim())
      setPage(0)
    }, 300)
    return () => clearTimeout(handle)
  }, [searchTerm])

  const timetableQuery = useQuery({
    queryKey: ['admin-timetable', 'list', debouncedSearch, page],
    queryFn: () =>
      fetchTimetable({ search: debouncedSearch, page, size: pageSize }),
    placeholderData: keepPreviousData,
    enabled: view === 'list',
  })

  const yearsQuery = useQuery({
    queryKey: ['admin-academic-years', 'list'],
    queryFn: fetchAcademicYears,
    enabled: view === 'grid',
  })

  const classOptions = useMemo(
    () =>
      (yearsQuery.data?.years ?? []).flatMap((year) =>
        year.classes.map((schoolClass) => ({
          key: `${year.name}||${schoolClass.name}`,
          label: `${schoolClass.name} — ${year.name}`,
          className: schoolClass.name,
          yearName: year.name,
        })),
      ),
    [yearsQuery.data],
  )

  useEffect(() => {
    if (view === 'grid' && !selectedClassKey && classOptions.length > 0) {
      setSelectedClassKey(classOptions[0].key)
    }
  }, [view, selectedClassKey, classOptions])

  const selectedClass = classOptions.find(
    (option) => option.key === selectedClassKey,
  )

  const gridQuery = useQuery({
    queryKey: [
      'admin-timetable',
      'grid',
      selectedClass?.yearName,
      selectedClass?.className,
    ],
    queryFn: () =>
      fetchTimetable({
        search: selectedClass?.className ?? '',
        page: 0,
        size: 200,
      }),
    enabled: view === 'grid' && selectedClass != null,
  })

  const classSlots = useMemo(
    () =>
      (gridQuery.data?.items ?? []).filter(
        (slot) =>
          slot.className === selectedClass?.className &&
          slot.academicYearName === selectedClass?.yearName,
      ),
    [gridQuery.data, selectedClass?.className, selectedClass?.yearName],
  )

  const semesterOptions = useMemo(
    () => [...new Set(classSlots.map((slot) => slot.semesterName))],
    [classSlots],
  )

  useEffect(() => {
    if (
      semesterOptions.length > 0 &&
      !semesterOptions.includes(selectedSemester)
    ) {
      setSelectedSemester(semesterOptions[0])
    }
  }, [semesterOptions, selectedSemester])

  const gridSlots = useMemo(
    () =>
      classSlots.filter((slot) => slot.semesterName === selectedSemester),
    [classSlots, selectedSemester],
  )

  const form = useForm<ImportDefaultsForm>({
    resolver: zodResolver(importDefaultsSchema),
    mode: 'onChange',
    defaultValues: {
      academicYearName: 'Năm học 2026',
      semesterName: 'Học kỳ 1',
      defaultClassName: 'Lớp 10A1',
    },
  })

  const mutation = useMutation({
    mutationFn: importTimetable,
    onSuccess: (result) => {
      toast.success(
        `Đã xử lý: ${result.createdSlots} tạo mới, ${result.updatedSlots} cập nhật, ${result.skippedRows} bỏ qua`,
      )
      queryClient.invalidateQueries({ queryKey: ['admin-timetable'] })
    },
    onError: (error) => {
      toast.error(
        error instanceof Error
          ? error.message
          : 'Nhập thời khóa biểu thất bại',
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

  const slots = timetableQuery.data?.items ?? []

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
      toast.error('Chưa có tiết học để nhập')
      return
    }

    mutation.mutate({
      academicYearName: values.academicYearName,
      semesterName: values.semesterName,
      defaultClassName: values.defaultClassName || undefined,
      slots: parsed.rows,
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
        <div className="flex flex-wrap items-center gap-2">
          <ViewToggle view={view} onViewChange={setView} />

          {view === 'list' ? (
            <Input
              aria-label="Tìm tiết học"
              value={searchTerm}
              onChange={(event) => setSearchTerm(event.target.value)}
              placeholder="Tìm lớp, môn, phòng, giáo viên"
              className="sm:w-72"
            />
          ) : (
            <>
              <Select
                value={selectedClassKey}
                onValueChange={setSelectedClassKey}
              >
                <SelectTrigger
                  aria-label="Chọn lớp"
                  className="w-full sm:w-60"
                >
                  <SelectValue placeholder="Chọn lớp" />
                </SelectTrigger>
                <SelectContent>
                  {classOptions.map((option) => (
                    <SelectItem key={option.key} value={option.key}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              {semesterOptions.length > 1 ? (
                <Select
                  value={selectedSemester}
                  onValueChange={setSelectedSemester}
                >
                  <SelectTrigger
                    aria-label="Chọn học kỳ"
                    className="w-full sm:w-40"
                  >
                    <SelectValue placeholder="Chọn học kỳ" />
                  </SelectTrigger>
                  <SelectContent>
                    {semesterOptions.map((semester) => (
                      <SelectItem key={semester} value={semester}>
                        {semester}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              ) : null}
            </>
          )}
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <Button type="button" variant="outline" onClick={downloadTemplate}>
            <Download className="size-4" />
            Tải mẫu CSV
          </Button>
          <Sheet open={importOpen} onOpenChange={changeImportOpen}>
            <SheetTrigger asChild>
              <Button type="button">
                <UploadCloud className="size-4" />
                Nhập TKB
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
        {view === 'list' ? (
          <TimetableListPanel
            isLoading={timetableQuery.isPending}
            page={page}
            result={timetableQuery.data}
            searchTerm={searchTerm}
            slots={slots}
            onOpenImport={() => setImportOpen(true)}
            onPageChange={setPage}
          />
        ) : (
          <div className="flex min-h-0 min-w-0 flex-1 flex-col rounded-md border bg-background">
            <TimetableWeeklyGrid
              slots={gridSlots}
              isLoading={
                yearsQuery.isPending ||
                (selectedClass != null && gridQuery.isPending)
              }
            />
            <div className="flex shrink-0 items-center justify-between border-t px-3 py-2 text-xs text-muted-foreground">
              <span className="tabular-nums">
                {gridSlots.length} tiết trong tuần
              </span>
              <span>{selectedSemester}</span>
            </div>
          </div>
        )}
      </section>
    </div>
  )
}

function ViewToggle({
  view,
  onViewChange,
}: {
  view: TimetableView
  onViewChange: (view: TimetableView) => void
}) {
  return (
    <div className="inline-flex rounded-md border p-0.5">
      <Button
        type="button"
        variant="ghost"
        size="sm"
        aria-pressed={view === 'list'}
        className={cn('h-7 px-2.5', view === 'list' && 'bg-muted')}
        onClick={() => onViewChange('list')}
      >
        <List className="size-4" />
        Danh sách
      </Button>
      <Button
        type="button"
        variant="ghost"
        size="sm"
        aria-pressed={view === 'grid'}
        className={cn('h-7 px-2.5', view === 'grid' && 'bg-muted')}
        onClick={() => onViewChange('grid')}
      >
        <LayoutGrid className="size-4" />
        Lưới tuần
      </Button>
    </div>
  )
}

function TimetableListPanel({
  isLoading,
  page,
  result,
  searchTerm,
  slots,
  onOpenImport,
  onPageChange,
}: {
  isLoading: boolean
  page: number
  result?: AdminTimetableListResponse
  searchTerm: string
  slots: AdminTimetableSlot[]
  onOpenImport: () => void
  onPageChange: (page: number) => void
}) {
  return (
    <div className="flex min-h-0 min-w-0 flex-1 flex-col rounded-md border bg-background">
      <div className="min-h-0 flex-1 overflow-auto">
        <DataTable
          columns={timetableColumns}
          data={slots}
          isLoading={isLoading}
          empty={
            <Empty className="min-h-[360px] border-0">
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <CalendarDays />
                </EmptyMedia>
                <EmptyTitle>
                  {searchTerm
                    ? 'Không tìm thấy tiết học'
                    : 'Chưa có thời khóa biểu'}
                </EmptyTitle>
                <EmptyDescription>
                  {searchTerm
                    ? 'Thử từ khóa khác hoặc xóa ô tìm kiếm.'
                    : 'Nhập CSV/Excel để tạo thời khóa biểu đầu tiên.'}
                </EmptyDescription>
              </EmptyHeader>
              {searchTerm ? null : (
                <Button type="button" variant="outline" onClick={onOpenImport}>
                  <UploadCloud className="size-4" />
                  Nhập TKB
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
        unitLabel="tiết học"
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
  result?: TimetableImportResponse
  onCsvTextChange: (value: string) => void
  onResetResult: () => void
  onSubmit: (values: ImportDefaultsForm) => void
  parsed: {
    rows: TimetableImportRow[]
    errors: string[]
  }
}) {
  return (
    <SheetContent className="w-full overflow-y-auto p-0 sm:max-w-4xl">
      <SheetHeader className="border-b px-6 py-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div className="space-y-1">
            <SheetTitle>
              {result
                ? 'Kết quả nhập thời khóa biểu'
                : 'Nhập thời khóa biểu từ CSV/Excel'}
            </SheetTitle>
            <SheetDescription>
              {result
                ? 'Kiểm tra từng tiết đã tạo mới, cập nhật hoặc bị bỏ qua.'
                : 'Cột bắt buộc: dayIndex (1 = thứ hai), lessonNumber, startsAt, endsAt; kèm title hoặc subjectCode.'}
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
            id="timetable-import-form"
            onSubmit={form.handleSubmit(onSubmit)}
            className="min-h-0 flex-1"
            noValidate
          >
            <div className="space-y-4 px-6 py-5">
              <div className="grid gap-4 sm:grid-cols-3">
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

                <FormField
                  control={form.control}
                  name="defaultClassName"
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
                <Label htmlFor="timetableCsv">Nội dung CSV</Label>
                <Textarea
                  id="timetableCsv"
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
                    Đọc được {parsed.rows.length} tiết học sẵn sàng nhập.
                  </AlertDescription>
                </Alert>
              ) : (
                <Alert>
                  <FileSpreadsheet />
                  <AlertTitle>Chưa có dòng dữ liệu</AlertTitle>
                  <AlertDescription>
                    Dán CSV hoặc chọn tệp có đủ cột dayIndex, lessonNumber,
                    startsAt và endsAt.
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
                form="timetable-import-form"
                disabled={!canSubmit}
              >
                {isPending ? (
                  <Loader2 className="size-4 animate-spin" />
                ) : (
                  <FileSpreadsheet className="size-4" />
                )}
                Nhập TKB
              </Button>
            </div>
          </>
        )}
      </SheetFooter>
    </SheetContent>
  )
}

function PreviewTable({ rows }: { rows: TimetableImportRow[] }) {
  if (rows.length === 0) {
    return null
  }

  return (
    <div className="rounded-md border">
      <div className="flex items-center justify-between border-b px-3 py-2">
        <h3 className="text-sm font-medium">Kiểm tra dữ liệu</h3>
        <span className="text-sm text-muted-foreground">
          {rows.length} tiết hợp lệ
        </span>
      </div>
      <div className="max-h-64 overflow-auto">
        <Table>
          <TableHeader className="sticky top-0 bg-background">
            <TableRow>
              <TableHead>Lớp</TableHead>
              <TableHead>Thứ</TableHead>
              <TableHead className="text-right">Tiết</TableHead>
              <TableHead>Nội dung</TableHead>
              <TableHead>Giờ</TableHead>
              <TableHead>Phòng</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {rows.map((row, index) => (
              <TableRow
                key={`${row.className}-${row.dayIndex}-${row.lessonNumber}-${index}`}
              >
                <TableCell>{row.className ?? 'Dùng mặc định'}</TableCell>
                <TableCell>
                  {dayIndexLabels[row.dayIndex] ?? `Thứ ${row.dayIndex}`}
                </TableCell>
                <TableCell className="text-right tabular-nums">
                  {row.lessonNumber}
                </TableCell>
                <TableCell>
                  {row.title ?? row.subjectName ?? row.subjectCode}
                </TableCell>
                <TableCell className="whitespace-nowrap tabular-nums">
                  {row.startsAt} - {row.endsAt}
                </TableCell>
                <TableCell>{row.roomName ?? '—'}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}

function ImportResultView({ result }: { result: TimetableImportResponse }) {
  return (
    <div className="space-y-4 px-6 py-5">
      <div className="grid gap-3 sm:grid-cols-3">
        <SummaryTile label="Tạo mới" value={result.createdSlots} />
        <SummaryTile label="Đã cập nhật" value={result.updatedSlots} />
        <SummaryTile label="Bị bỏ qua" value={result.skippedRows} />
      </div>

      <div className="rounded-md border">
        <div className="max-h-[28rem] overflow-auto">
          <Table>
            <TableHeader className="sticky top-0 bg-background">
              <TableRow>
                <TableHead className="w-16">STT</TableHead>
                <TableHead>Lớp</TableHead>
                <TableHead>Thứ</TableHead>
                <TableHead className="text-right">Tiết</TableHead>
                <TableHead>Kết quả</TableHead>
                <TableHead>Ghi chú</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {result.rows.map((row) => (
                <TableRow key={`${row.rowNumber}-${row.className}`}>
                  <TableCell className="tabular-nums">
                    {row.rowNumber}
                  </TableCell>
                  <TableCell className="font-medium">{row.className}</TableCell>
                  <TableCell>
                    {dayIndexLabels[row.dayIndex] ?? row.dayIndex}
                  </TableCell>
                  <TableCell className="text-right tabular-nums">
                    {row.lessonNumber}
                  </TableCell>
                  <TableCell>
                    <TimetableStatusBadge status={row.status} />
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

function TimetableStatusBadge({
  status,
}: {
  status: TimetableImportRowResult['status']
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
  anchor.download = 'mau-nhap-tkb.csv'
  anchor.click()
  URL.revokeObjectURL(url)
}
