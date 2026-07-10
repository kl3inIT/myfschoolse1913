import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { toast } from 'sonner'
import { z } from 'zod'
import { CalendarRange, Loader2, Plus, School } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
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
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  createAcademicYear,
  createSchoolClass,
  fetchAcademicYears,
  type AdminAcademicYear,
} from '@/lib/academic-years'

const createYearSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, 'Vui lòng nhập tên năm học')
    .max(40, 'Tên năm học tối đa 40 ký tự'),
  startsOn: z.string(),
  endsOn: z.string(),
  currentYear: z.boolean(),
})

type CreateYearForm = z.infer<typeof createYearSchema>

export function ClassManagementPage() {
  const yearsQuery = useQuery({
    queryKey: ['admin-academic-years'],
    queryFn: fetchAcademicYears,
  })

  const years = yearsQuery.data?.years ?? []

  return (
    <div className="flex min-h-[calc(100vh-8rem)] flex-col gap-4">
      <section className="flex items-center justify-end">
        <CreateYearDialog />
      </section>

      <section className="flex min-w-0 flex-1 flex-col gap-4">
        {yearsQuery.isPending ? (
          <YearListSkeleton />
        ) : years.length > 0 ? (
          years.map((year) => <AcademicYearCard key={year.id} year={year} />)
        ) : (
          <Empty className="min-h-[360px] rounded-md border">
            <EmptyHeader>
              <EmptyMedia variant="icon">
                <CalendarRange />
              </EmptyMedia>
              <EmptyTitle>Chưa có năm học</EmptyTitle>
              <EmptyDescription>
                Tạo năm học đầu tiên để bắt đầu quản lý lớp.
              </EmptyDescription>
            </EmptyHeader>
            <CreateYearDialog />
          </Empty>
        )}
      </section>
    </div>
  )
}

function CreateYearDialog() {
  const [open, setOpen] = useState(false)
  const queryClient = useQueryClient()

  const form = useForm<CreateYearForm>({
    resolver: zodResolver(createYearSchema),
    defaultValues: {
      name: '',
      startsOn: '',
      endsOn: '',
      currentYear: false,
    },
  })

  const mutation = useMutation({
    mutationFn: createAcademicYear,
    onSuccess: (year) => {
      toast.success(`Đã tạo năm học "${year.name}"`)
      form.reset()
      queryClient.invalidateQueries({ queryKey: ['admin-academic-years'] })
      setOpen(false)
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Tạo năm học thất bại',
      )
    },
  })

  function changeOpen(nextOpen: boolean) {
    setOpen(nextOpen)
    if (nextOpen) {
      form.reset()
    }
  }

  return (
    <Dialog open={open} onOpenChange={changeOpen}>
      <DialogTrigger asChild>
        <Button type="button">
          <Plus className="size-4" />
          Thêm năm học
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Thêm năm học</DialogTitle>
          <DialogDescription>
            Lớp học luôn thuộc về một năm học cụ thể.
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form
            id="create-year-form"
            onSubmit={form.handleSubmit((values) =>
              mutation.mutate({
                name: values.name,
                startsOn: values.startsOn || undefined,
                endsOn: values.endsOn || undefined,
                currentYear: values.currentYear,
              }),
            )}
            className="space-y-4"
            noValidate
          >
            <FormField
              control={form.control}
              name="name"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Tên năm học</FormLabel>
                  <FormControl>
                    <Input
                      autoComplete="off"
                      placeholder="VD: Năm học 2027"
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
                name="startsOn"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Bắt đầu</FormLabel>
                    <FormControl>
                      <Input type="date" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="endsOn"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Kết thúc</FormLabel>
                    <FormControl>
                      <Input type="date" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name="currentYear"
              render={({ field }) => (
                <FormItem className="flex flex-row items-center gap-2 space-y-0">
                  <FormControl>
                    <Checkbox
                      checked={field.value}
                      onCheckedChange={(checked) =>
                        field.onChange(checked === true)
                      }
                    />
                  </FormControl>
                  <FormLabel className="font-normal">
                    Đặt làm năm học hiện tại
                  </FormLabel>
                </FormItem>
              )}
            />
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
            form="create-year-form"
            disabled={mutation.isPending}
          >
            {mutation.isPending ? (
              <Loader2 className="size-4 animate-spin" />
            ) : (
              <Plus className="size-4" />
            )}
            Tạo năm học
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

function AcademicYearCard({ year }: { year: AdminAcademicYear }) {
  return (
    <div className="rounded-md border bg-background">
      <div className="flex flex-col gap-2 border-b p-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <h3 className="text-sm font-semibold">{year.name}</h3>
            {year.currentYear ? <Badge>Năm hiện tại</Badge> : null}
          </div>
          <p className="text-sm text-muted-foreground">
            {formatYearRange(year)} · {year.classes.length} lớp ·{' '}
            {totalStudents(year)} học sinh
          </p>
        </div>
        <AddClassForm yearId={year.id} />
      </div>

      {year.classes.length > 0 ? (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Tên lớp</TableHead>
              <TableHead className="w-32 text-right">Sĩ số</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {year.classes.map((schoolClass) => (
              <TableRow key={schoolClass.id}>
                <TableCell className="font-medium">
                  <div className="flex items-center gap-2">
                    <School className="size-3.5 text-muted-foreground" />
                    {schoolClass.name}
                  </div>
                </TableCell>
                <TableCell className="text-right tabular-nums">
                  {schoolClass.studentCount}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      ) : (
        <p className="p-4 text-sm text-muted-foreground">
          Chưa có lớp trong năm học này.
        </p>
      )}
    </div>
  )
}

function AddClassForm({ yearId }: { yearId: string }) {
  const [name, setName] = useState('')
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: createSchoolClass,
    onSuccess: (schoolClass) => {
      toast.success(`Đã tạo lớp "${schoolClass.name}"`)
      setName('')
      queryClient.invalidateQueries({ queryKey: ['admin-academic-years'] })
    },
    onError: (error) => {
      toast.error(error instanceof Error ? error.message : 'Tạo lớp thất bại')
    },
  })

  function submit(event: React.FormEvent) {
    event.preventDefault()
    const trimmed = name.trim()
    if (!trimmed) {
      toast.error('Vui lòng nhập tên lớp')
      return
    }
    mutation.mutate({ yearId, name: trimmed })
  }

  return (
    <form onSubmit={submit} className="flex items-center gap-2">
      <Input
        aria-label="Tên lớp mới"
        value={name}
        onChange={(event) => setName(event.target.value)}
        placeholder="VD: Lớp 10A2"
        className="h-8 w-40"
      />
      <Button
        type="submit"
        variant="outline"
        size="sm"
        disabled={mutation.isPending}
      >
        {mutation.isPending ? (
          <Loader2 className="size-3.5 animate-spin" />
        ) : (
          <Plus className="size-3.5" />
        )}
        Thêm lớp
      </Button>
    </form>
  )
}

function YearListSkeleton() {
  return (
    <div className="space-y-4">
      {Array.from({ length: 2 }, (_, index) => (
        <div key={index} className="space-y-3 rounded-md border p-4">
          <Skeleton className="h-5 w-48" />
          <Skeleton className="h-4 w-64" />
          <Skeleton className="h-24" />
        </div>
      ))}
    </div>
  )
}

function formatYearRange(year: AdminAcademicYear) {
  if (!year.startsOn && !year.endsOn) {
    return 'Chưa đặt thời gian'
  }
  return `${formatDate(year.startsOn)} – ${formatDate(year.endsOn)}`
}

function formatDate(value: string | null) {
  if (!value) {
    return '?'
  }
  return new Date(value).toLocaleDateString('vi-VN')
}

function totalStudents(year: AdminAcademicYear) {
  return year.classes.reduce(
    (total, schoolClass) => total + schoolClass.studentCount,
    0,
  )
}
