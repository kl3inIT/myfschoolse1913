import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useParams, useSearch } from '@tanstack/react-router'
import { useEffect, useState } from 'react'
import { useForm, type UseFormReturn } from 'react-hook-form'
import { toast } from 'sonner'
import { z } from 'zod'
import {
  ArrowLeft,
  GraduationCap,
  Loader2,
  Pencil,
  Phone,
  UserRound,
  Users,
  X,
} from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Checkbox } from '@/components/ui/checkbox'
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
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { Separator } from '@/components/ui/separator'
import { Skeleton } from '@/components/ui/skeleton'
import {
  fetchStudent,
  updateStudent,
  type AdminStudent,
} from '@/lib/students'

const editStudentSchema = z.object({
  fullName: z
    .string()
    .trim()
    .min(1, 'Vui lòng nhập họ tên')
    .max(120, 'Họ tên tối đa 120 ký tự'),
  phoneNumber: z
    .string()
    .trim()
    .min(1, 'Vui lòng nhập số điện thoại')
    .max(20, 'Số điện thoại tối đa 20 ký tự'),
  studentCode: z
    .string()
    .trim()
    .min(1, 'Vui lòng nhập mã học sinh')
    .max(40, 'Mã học sinh tối đa 40 ký tự'),
  academicYearName: z
    .string()
    .trim()
    .min(1, 'Vui lòng nhập năm học')
    .max(40, 'Năm học tối đa 40 ký tự'),
  className: z
    .string()
    .trim()
    .min(1, 'Vui lòng nhập lớp')
    .max(40, 'Lớp tối đa 40 ký tự'),
  status: z
    .string()
    .trim()
    .min(1, 'Vui lòng nhập trạng thái')
    .max(40, 'Trạng thái tối đa 40 ký tự'),
  accountEnabled: z.boolean(),
  newPassword: z
    .string()
    .refine((value) => value === '' || value.length >= 8, {
      message: 'Mật khẩu mới tối thiểu 8 ký tự',
    }),
})

type EditStudentForm = z.infer<typeof editStudentSchema>

function editFormValues(student: AdminStudent): EditStudentForm {
  return {
    fullName: student.fullName,
    phoneNumber: student.phoneNumber,
    studentCode: student.studentCode,
    academicYearName: student.academicYearName,
    className: student.className,
    status: student.status,
    accountEnabled: student.accountEnabled,
    newPassword: '',
  }
}

export function StudentDetailPage() {
  const { studentId } = useParams({ from: '/students/$studentId' })
  const { edit } = useSearch({ from: '/students/$studentId' })
  const [editing, setEditing] = useState(false)
  const [autoEditApplied, setAutoEditApplied] = useState(false)
  const queryClient = useQueryClient()

  const studentQuery = useQuery({
    queryKey: ['admin-students', 'detail', studentId],
    queryFn: () => fetchStudent(studentId),
    retry: false,
  })

  const form = useForm<EditStudentForm>({
    resolver: zodResolver(editStudentSchema),
    defaultValues: {
      fullName: '',
      phoneNumber: '',
      studentCode: '',
      academicYearName: '',
      className: '',
      status: '',
      accountEnabled: true,
      newPassword: '',
    },
  })

  const mutation = useMutation({
    mutationFn: (values: EditStudentForm) =>
      updateStudent(studentId, {
        ...values,
        newPassword: values.newPassword || undefined,
      }),
    onSuccess: () => {
      toast.success('Đã lưu thông tin học sinh')
      queryClient.invalidateQueries({ queryKey: ['admin-students'] })
      setEditing(false)
    },
    onError: (error) => {
      toast.error(
        error instanceof Error ? error.message : 'Lưu thông tin thất bại',
      )
    },
  })

  function startEditing() {
    if (!studentQuery.data) {
      return
    }
    form.reset(editFormValues(studentQuery.data))
    setEditing(true)
  }

  useEffect(() => {
    if (edit && studentQuery.data && !autoEditApplied) {
      form.reset(editFormValues(studentQuery.data))
      setEditing(true)
      setAutoEditApplied(true)
    }
  }, [edit, studentQuery.data, autoEditApplied, form])

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between gap-2">
        <Button asChild type="button" variant="outline" size="sm">
          <Link to="/students">
            <ArrowLeft className="size-4" />
            Về danh sách
          </Link>
        </Button>

        {studentQuery.data ? (
          editing ? (
            <div className="flex items-center gap-2">
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={() => setEditing(false)}
                disabled={mutation.isPending}
              >
                <X className="size-4" />
                Hủy
              </Button>
              <Button
                type="submit"
                form="edit-student-form"
                size="sm"
                disabled={mutation.isPending}
              >
                {mutation.isPending ? (
                  <Loader2 className="size-4 animate-spin" />
                ) : null}
                Lưu thay đổi
              </Button>
            </div>
          ) : (
            <Button type="button" size="sm" onClick={startEditing}>
              <Pencil className="size-4" />
              Chỉnh sửa
            </Button>
          )
        ) : null}
      </div>

      {studentQuery.isPending ? (
        <StudentDetailSkeleton />
      ) : studentQuery.data ? (
        <Form {...form}>
          <form
            id="edit-student-form"
            onSubmit={form.handleSubmit((values) => mutation.mutate(values))}
            noValidate
          >
            <StudentDetailContent
              student={studentQuery.data}
              editing={editing}
              form={form}
            />
          </form>
        </Form>
      ) : (
        <Empty className="min-h-[360px]">
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <Users />
            </EmptyMedia>
            <EmptyTitle>Không tìm thấy học sinh</EmptyTitle>
            <EmptyDescription>
              Học sinh không tồn tại hoặc đã bị xóa khỏi hệ thống.
            </EmptyDescription>
          </EmptyHeader>
          <Button asChild type="button" variant="outline">
            <Link to="/students">
              <ArrowLeft className="size-4" />
              Về danh sách
            </Link>
          </Button>
        </Empty>
      )}
    </div>
  )
}

function StudentDetailContent({
  student,
  editing,
  form,
}: {
  student: AdminStudent
  editing: boolean
  form: UseFormReturn<EditStudentForm>
}) {
  return (
    <div className="grid gap-4 xl:grid-cols-[minmax(0,1fr)_360px]">
      <Card>
        <CardHeader>
          <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
            <div className="space-y-1">
              <CardTitle className="text-lg">{student.fullName}</CardTitle>
              <CardDescription className="font-mono">
                {student.studentCode}
              </CardDescription>
            </div>
            <div className="flex items-center gap-2">
              <Badge
                variant={student.status === 'Đang học' ? 'default' : 'outline'}
              >
                {student.status}
              </Badge>
              {student.accountEnabled ? null : (
                <Badge variant="destructive">Tài khoản khóa</Badge>
              )}
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-5">
          <section className="space-y-3">
            <h3 className="flex items-center gap-2 text-sm font-medium">
              <UserRound className="size-4 text-muted-foreground" />
              Hồ sơ
            </h3>
            <dl className="grid gap-3 sm:grid-cols-2">
              <EditableField
                editing={editing}
                form={form}
                name="studentCode"
                label="Mã học sinh"
                value={student.studentCode}
              />
              <EditableField
                editing={editing}
                form={form}
                name="fullName"
                label="Họ và tên"
                value={student.fullName}
              />
              <EditableField
                editing={editing}
                form={form}
                name="status"
                label="Trạng thái"
                value={student.status}
              />
            </dl>
          </section>

          <Separator />

          <section className="space-y-3">
            <h3 className="flex items-center gap-2 text-sm font-medium">
              <GraduationCap className="size-4 text-muted-foreground" />
              Lớp học
            </h3>
            <dl className="grid gap-3 sm:grid-cols-2">
              <EditableField
                editing={editing}
                form={form}
                name="className"
                label="Lớp"
                value={student.className}
              />
              <EditableField
                editing={editing}
                form={form}
                name="academicYearName"
                label="Năm học"
                value={student.academicYearName}
              />
            </dl>
          </section>
        </CardContent>
      </Card>

      <Card className="h-fit">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            <Phone className="size-4 text-muted-foreground" />
            Tài khoản đăng nhập
          </CardTitle>
          <CardDescription>
            Học sinh đăng nhập app bằng số điện thoại này.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <dl className="space-y-3">
            <EditableField
              editing={editing}
              form={form}
              name="phoneNumber"
              label="Số điện thoại"
              value={student.phoneNumber}
            />

            {editing ? (
              <>
                <EditableField
                  editing
                  form={form}
                  name="newPassword"
                  label="Mật khẩu mới (bỏ trống nếu giữ nguyên)"
                  value=""
                  type="password"
                />
                <div className="space-y-1">
                  <dt className="text-xs font-medium uppercase text-muted-foreground">
                    Tài khoản
                  </dt>
                  <dd>
                    <FormField
                      control={form.control}
                      name="accountEnabled"
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
                          <span className="text-sm">
                            Được phép đăng nhập
                          </span>
                        </FormItem>
                      )}
                    />
                  </dd>
                </div>
              </>
            ) : (
              <StaticField
                label="Trạng thái tài khoản"
                value={student.accountEnabled ? 'Đang hoạt động' : 'Đã khóa'}
              />
            )}
          </dl>
        </CardContent>
      </Card>
    </div>
  )
}

function EditableField({
  editing,
  form,
  name,
  label,
  value,
  type = 'text',
}: {
  editing: boolean
  form: UseFormReturn<EditStudentForm>
  name: Exclude<keyof EditStudentForm, 'accountEnabled'>
  label: string
  value: string
  type?: string
}) {
  if (!editing) {
    return <StaticField label={label} value={value} />
  }

  return (
    <div className="space-y-1">
      <dt className="text-xs font-medium uppercase text-muted-foreground">
        {label}
      </dt>
      <dd>
        <FormField
          control={form.control}
          name={name}
          render={({ field }) => (
            <FormItem>
              <FormControl>
                <Input
                  type={type}
                  autoComplete={type === 'password' ? 'new-password' : 'off'}
                  className="h-8"
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
      </dd>
    </div>
  )
}

function StaticField({ label, value }: { label: string; value: string }) {
  return (
    <div className="space-y-1">
      <dt className="text-xs font-medium uppercase text-muted-foreground">
        {label}
      </dt>
      <dd className="break-words text-sm">{value}</dd>
    </div>
  )
}

function StudentDetailSkeleton() {
  return (
    <div className="grid gap-4 xl:grid-cols-[minmax(0,1fr)_360px]">
      <div className="space-y-4 rounded-md border p-6">
        <Skeleton className="h-6 w-48" />
        <Skeleton className="h-4 w-32" />
        <div className="grid gap-3 sm:grid-cols-2">
          {Array.from({ length: 4 }, (_, index) => (
            <Skeleton key={index} className="h-10" />
          ))}
        </div>
      </div>
      <div className="space-y-4 rounded-md border p-6">
        <Skeleton className="h-5 w-40" />
        <Skeleton className="h-10" />
        <Skeleton className="h-10" />
      </div>
    </div>
  )
}
