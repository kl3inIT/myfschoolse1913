import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useState } from 'react'
import { toast } from 'sonner'
import {
  BookOpenCheck,
  FilePenLine,
  Link2,
  Loader2,
  Plus,
  UserRoundCheck,
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
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Skeleton } from '@/components/ui/skeleton'
import { Textarea } from '@/components/ui/textarea'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  assignHomeroom,
  assignTeacher,
  correctPublishedAssessment,
  createParent,
  createTeacher,
  fetchAdminSchoolWork,
  linkGuardian,
  type AdminSchoolWork,
  type GuardianRelationship,
} from '@/lib/school-work'

const selectClass =
  'h-9 w-full rounded-md border border-input bg-transparent px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50'

export function SchoolWorkManagementPage() {
  const query = useQuery({
    queryKey: ['admin-school-work'],
    queryFn: fetchAdminSchoolWork,
  })

  if (query.isPending) {
    return (
      <div className="grid gap-4 lg:grid-cols-2">
        <Skeleton className="h-72" />
        <Skeleton className="h-72" />
      </div>
    )
  }
  if (!query.data) {
    return (
      <p className="text-sm text-destructive">
        Không tải được dữ liệu phân công.
      </p>
    )
  }

  return (
    <div className="space-y-6">
      <section className="grid gap-4 md:grid-cols-3">
        <Summary
          label="Giáo viên"
          value={query.data.teachers.length}
          detail={`${query.data.teachingAssignments.filter((item) => item.active).length} phân công bộ môn`}
        />
        <Summary
          label="Lớp chủ nhiệm"
          value={
            query.data.homeroomAssignments.filter((item) => item.active).length
          }
          detail="Mỗi lớp một GVCN đang hoạt động"
        />
        <Summary
          label="Liên kết phụ huynh"
          value={query.data.guardianLinks.filter((item) => item.active).length}
          detail={`${query.data.parents.length} tài khoản phụ huynh`}
        />
      </section>

      <section className="grid gap-4 xl:grid-cols-2">
        <AccountCard data={query.data} />
        <AssignmentCard data={query.data} />
        <HomeroomCard data={query.data} />
        <GuardianCard data={query.data} />
      </section>

      <GradeCorrectionCard data={query.data} />

      <section className="grid gap-4 xl:grid-cols-2">
        <TeachingTable data={query.data} />
        <GuardianTable data={query.data} />
      </section>
    </div>
  )
}

function Summary({
  label,
  value,
  detail,
}: {
  label: string
  value: number
  detail: string
}) {
  return (
    <Card>
      <CardHeader className="pb-2">
        <CardDescription>{label}</CardDescription>
        <CardTitle className="text-3xl tabular-nums">{value}</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-xs text-muted-foreground">{detail}</p>
      </CardContent>
    </Card>
  )
}

function AccountCard({ data }: { data: AdminSchoolWork }) {
  const queryClient = useQueryClient()
  const [kind, setKind] = useState<'teacher' | 'parent'>('teacher')
  const [fullName, setFullName] = useState('')
  const [phoneNumber, setPhoneNumber] = useState('')
  const [employeeCode, setEmployeeCode] = useState('')
  const mutation = useMutation({
    mutationFn: () =>
      kind === 'teacher'
        ? createTeacher({
            fullName,
            phoneNumber,
            employeeCode,
            initialPassword: 'Password123',
          })
        : createParent({
            fullName,
            phoneNumber,
            initialPassword: 'Password123',
          }),
    onSuccess: () => {
      toast.success(
        `Đã tạo tài khoản ${kind === 'teacher' ? 'giáo viên' : 'phụ huynh'}`,
      )
      setFullName('')
      setPhoneNumber('')
      setEmployeeCode('')
      void queryClient.invalidateQueries({ queryKey: ['admin-school-work'] })
    },
    onError: showError,
  })

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-base">
          <UserRoundCheck className="size-4" />
          Tài khoản nhà trường
        </CardTitle>
        <CardDescription>
          Tạo hồ sơ đúng vai trò. Mật khẩu demo ban đầu là Password123.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form
          className="grid gap-3 sm:grid-cols-2"
          onSubmit={(event) => {
            event.preventDefault()
            mutation.mutate()
          }}
        >
          <Field label="Vai trò">
            <select
              className={selectClass}
              value={kind}
              onChange={(event) =>
                setKind(event.target.value as 'teacher' | 'parent')
              }
            >
              <option value="teacher">Giáo viên</option>
              <option value="parent">Phụ huynh</option>
            </select>
          </Field>
          <Field label="Họ và tên">
            <Input
              value={fullName}
              onChange={(event) => setFullName(event.target.value)}
              required
            />
          </Field>
          <Field label="Số điện thoại">
            <Input
              value={phoneNumber}
              onChange={(event) => setPhoneNumber(event.target.value)}
              required
            />
          </Field>
          {kind === 'teacher' ? (
            <Field label="Mã giáo viên">
              <Input
                value={employeeCode}
                onChange={(event) => setEmployeeCode(event.target.value)}
                required
              />
            </Field>
          ) : (
            <div />
          )}
          <div className="sm:col-span-2 flex items-center justify-between">
            <p className="text-xs text-muted-foreground">
              Hiện có {data.teachers.length} giáo viên, {data.parents.length}{' '}
              phụ huynh.
            </p>
            <SubmitButton pending={mutation.isPending}>
              Tạo tài khoản
            </SubmitButton>
          </div>
        </form>
      </CardContent>
    </Card>
  )
}

function AssignmentCard({ data }: { data: AdminSchoolWork }) {
  const queryClient = useQueryClient()
  const [teacherId, setTeacherId] = useState(data.teachers[0]?.id ?? '')
  const [classId, setClassId] = useState(data.classes[0]?.id ?? '')
  const [subjectId, setSubjectId] = useState(data.subjects[0]?.id ?? '')
  const matchingClass = data.classes.find((item) => item.id === classId)
  const semesters = data.semesters.filter(
    (item) => item.academicYearId === matchingClass?.academicYearId,
  )
  const [semesterId, setSemesterId] = useState('')
  const effectiveSemester = semesters.some((item) => item.id === semesterId)
    ? semesterId
    : (semesters[0]?.id ?? '')
  const mutation = useMutation({
    mutationFn: () =>
      assignTeacher({
        teacherId,
        classId,
        subjectId,
        semesterId: effectiveSemester,
        type: 'PRIMARY',
        active: true,
      }),
    onSuccess: () => {
      toast.success('Đã lưu phân công bộ môn')
      void queryClient.invalidateQueries({ queryKey: ['admin-school-work'] })
    },
    onError: showError,
  })
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-base">
          <BookOpenCheck className="size-4" />
          Phân công bộ môn
        </CardTitle>
        <CardDescription>
          Quyền xem lớp và nhập điểm được suy ra từ phân công này.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form
          className="grid gap-3 sm:grid-cols-2"
          onSubmit={(event) => {
            event.preventDefault()
            mutation.mutate()
          }}
        >
          <SelectField
            label="Giáo viên"
            value={teacherId}
            onChange={setTeacherId}
            items={data.teachers.map((item) => ({
              value: item.id,
              label: `${item.employeeCode} · ${item.fullName}`,
            }))}
          />
          <SelectField
            label="Lớp"
            value={classId}
            onChange={(value) => {
              setClassId(value)
              setSemesterId('')
            }}
            items={data.classes.map((item) => ({
              value: item.id,
              label: `${item.name} · ${item.academicYearName}`,
            }))}
          />
          <SelectField
            label="Môn"
            value={subjectId}
            onChange={setSubjectId}
            items={data.subjects.map((item) => ({
              value: item.id,
              label: item.name,
            }))}
          />
          <SelectField
            label="Học kỳ"
            value={effectiveSemester}
            onChange={setSemesterId}
            items={semesters.map((item) => ({
              value: item.id,
              label: item.name,
            }))}
          />
          <div className="sm:col-span-2 flex justify-end">
            <SubmitButton pending={mutation.isPending}>
              Lưu phân công
            </SubmitButton>
          </div>
        </form>
      </CardContent>
    </Card>
  )
}

function HomeroomCard({ data }: { data: AdminSchoolWork }) {
  const queryClient = useQueryClient()
  const [teacherId, setTeacherId] = useState(data.teachers[0]?.id ?? '')
  const [classId, setClassId] = useState(data.classes[0]?.id ?? '')
  const schoolClass = data.classes.find((item) => item.id === classId)
  const mutation = useMutation({
    mutationFn: () =>
      assignHomeroom({
        teacherId,
        classId,
        academicYearId: schoolClass?.academicYearId ?? '',
        active: true,
      }),
    onSuccess: () => {
      toast.success('Đã lưu giáo viên chủ nhiệm')
      void queryClient.invalidateQueries({ queryKey: ['admin-school-work'] })
    },
    onError: showError,
  })
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">Giáo viên chủ nhiệm</CardTitle>
        <CardDescription>
          GVCN được duyệt đơn ngắn hạn và tổng hợp rèn luyện của đúng lớp.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form
          className="grid gap-3 sm:grid-cols-2"
          onSubmit={(event) => {
            event.preventDefault()
            mutation.mutate()
          }}
        >
          <SelectField
            label="Giáo viên"
            value={teacherId}
            onChange={setTeacherId}
            items={data.teachers.map((item) => ({
              value: item.id,
              label: item.fullName,
            }))}
          />
          <SelectField
            label="Lớp / năm học"
            value={classId}
            onChange={setClassId}
            items={data.classes.map((item) => ({
              value: item.id,
              label: `${item.name} · ${item.academicYearName}`,
            }))}
          />
          <div className="sm:col-span-2 flex justify-end">
            <SubmitButton pending={mutation.isPending}>
              Giao chủ nhiệm
            </SubmitButton>
          </div>
        </form>
      </CardContent>
    </Card>
  )
}

function GuardianCard({ data }: { data: AdminSchoolWork }) {
  const queryClient = useQueryClient()
  const [parentId, setParentId] = useState(data.parents[0]?.id ?? '')
  const [studentId, setStudentId] = useState(data.students[0]?.id ?? '')
  const [relationship, setRelationship] =
    useState<GuardianRelationship>('MOTHER')
  const [primaryContact, setPrimaryContact] = useState(true)
  const mutation = useMutation({
    mutationFn: () =>
      linkGuardian({
        parentId,
        studentId,
        relationship,
        primaryContact,
        active: true,
      }),
    onSuccess: () => {
      toast.success('Đã xác minh liên kết phụ huynh – học sinh')
      void queryClient.invalidateQueries({ queryKey: ['admin-school-work'] })
    },
    onError: showError,
  })
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-base">
          <Link2 className="size-4" />
          Liên kết người giám hộ
        </CardTitle>
        <CardDescription>
          Phụ huynh chỉ xem được học sinh đã được nhà trường xác minh.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form
          className="grid gap-3 sm:grid-cols-2"
          onSubmit={(event) => {
            event.preventDefault()
            mutation.mutate()
          }}
        >
          <SelectField
            label="Phụ huynh"
            value={parentId}
            onChange={setParentId}
            items={data.parents.map((item) => ({
              value: item.id,
              label: `${item.fullName} · ${item.phoneNumber}`,
            }))}
          />
          <SelectField
            label="Học sinh"
            value={studentId}
            onChange={setStudentId}
            items={data.students.map((item) => ({
              value: item.id,
              label: `${item.studentCode} · ${item.fullName} · ${item.className}`,
            }))}
          />
          <SelectField
            label="Quan hệ"
            value={relationship}
            onChange={(value) => setRelationship(value as GuardianRelationship)}
            items={[
              { value: 'MOTHER', label: 'Mẹ' },
              { value: 'FATHER', label: 'Bố' },
              { value: 'GUARDIAN', label: 'Người giám hộ' },
            ]}
          />
          <div className="flex items-end gap-2 pb-2">
            <Checkbox
              id="primary"
              checked={primaryContact}
              onCheckedChange={(value) => setPrimaryContact(value === true)}
            />
            <Label htmlFor="primary">Liên hệ chính</Label>
          </div>
          <div className="sm:col-span-2 flex justify-end">
            <SubmitButton pending={mutation.isPending}>
              Xác minh liên kết
            </SubmitButton>
          </div>
        </form>
      </CardContent>
    </Card>
  )
}

function GradeCorrectionCard({ data }: { data: AdminSchoolWork }) {
  const queryClient = useQueryClient()
  const firstResult = data.publishedAssessments[0]
  const [resultId, setResultId] = useState(firstResult?.id ?? '')
  const selected =
    data.publishedAssessments.find((item) => item.id === resultId) ??
    firstResult
  const [score, setScore] = useState(firstResult?.score.toString() ?? '')
  const [comment, setComment] = useState(firstResult?.comment ?? '')
  const [reason, setReason] = useState('')
  const mutation = useMutation({
    mutationFn: () =>
      correctPublishedAssessment(selected?.id ?? '', {
        score: Number(score),
        comment,
        reason,
      }),
    onSuccess: () => {
      toast.success('Đã hiệu chỉnh điểm và lưu lịch sử thay đổi')
      setReason('')
      void queryClient.invalidateQueries({ queryKey: ['admin-school-work'] })
    },
    onError: showError,
  })

  const chooseResult = (id: string) => {
    const result = data.publishedAssessments.find((item) => item.id === id)
    setResultId(id)
    setScore(result?.score.toString() ?? '')
    setComment(result?.comment ?? '')
    setReason('')
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-base">
          <FilePenLine className="size-4" />
          Hiệu chỉnh điểm đã công bố
        </CardTitle>
        <CardDescription>
          Giáo viên không sửa trực tiếp điểm đã công bố. Quản trị viên phải ghi
          lý do; hệ thống lưu vết và tính lại điểm trung bình.
        </CardDescription>
      </CardHeader>
      <CardContent>
        {data.publishedAssessments.length === 0 ? (
          <p className="text-sm text-muted-foreground">
            Chưa có điểm đã công bố để hiệu chỉnh.
          </p>
        ) : (
          <form
            className="grid gap-3 lg:grid-cols-[minmax(0,2fr)_8rem_minmax(0,1fr)]"
            onSubmit={(event) => {
              event.preventDefault()
              mutation.mutate()
            }}
          >
            <SelectField
              label="Kết quả"
              value={selected?.id ?? ''}
              onChange={chooseResult}
              items={data.publishedAssessments.map((item) => ({
                value: item.id,
                label: `${item.studentCode} · ${item.studentName} · ${item.subjectName} · ${assessmentLabel(item.type, item.sequenceNumber)} · ${item.score}`,
              }))}
            />
            <Field label="Điểm mới">
              <Input
                type="number"
                min="0"
                max="10"
                step="0.1"
                value={score}
                onChange={(event) => setScore(event.target.value)}
                required
              />
            </Field>
            <Field label="Nhận xét">
              <Input
                value={comment}
                maxLength={255}
                onChange={(event) => setComment(event.target.value)}
              />
            </Field>
            <div className="lg:col-span-3 space-y-1.5">
              <Label htmlFor="correction-reason">Lý do hiệu chỉnh</Label>
              <Textarea
                id="correction-reason"
                value={reason}
                maxLength={500}
                onChange={(event) => setReason(event.target.value)}
                placeholder="Ví dụ: Đối chiếu lại bài kiểm tra gốc theo biên bản..."
                required
              />
            </div>
            <div className="lg:col-span-3 flex items-center justify-between gap-3">
              <p className="text-xs text-muted-foreground">
                {selected?.className} · {selected?.semesterName} ·{' '}
                {selected?.title}
              </p>
              <SubmitButton pending={mutation.isPending}>
                Lưu hiệu chỉnh
              </SubmitButton>
            </div>
          </form>
        )}
      </CardContent>
    </Card>
  )
}

function TeachingTable({ data }: { data: AdminSchoolWork }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">Phân công đang có</CardTitle>
      </CardHeader>
      <CardContent className="px-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Giáo viên</TableHead>
              <TableHead>Phạm vi</TableHead>
              <TableHead>Trạng thái</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.teachingAssignments.map((item) => (
              <TableRow key={item.id}>
                <TableCell className="font-medium">
                  {item.teacherName}
                </TableCell>
                <TableCell>
                  {item.subjectName} · {item.className} · {item.semesterName}
                </TableCell>
                <TableCell>
                  <Badge variant={item.active ? 'default' : 'secondary'}>
                    {item.active ? 'Hiệu lực' : 'Đã dừng'}
                  </Badge>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  )
}

function GuardianTable({ data }: { data: AdminSchoolWork }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">Phụ huynh – học sinh</CardTitle>
      </CardHeader>
      <CardContent className="px-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Phụ huynh</TableHead>
              <TableHead>Học sinh</TableHead>
              <TableHead>Quan hệ</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.guardianLinks.map((item) => (
              <TableRow key={item.id}>
                <TableCell className="font-medium">{item.parentName}</TableCell>
                <TableCell>
                  {item.studentName} · {item.className}
                </TableCell>
                <TableCell>
                  {relationshipLabel(item.relationship)}
                  {item.primaryContact ? ' · Chính' : ''}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  )
}

function Field({
  label,
  children,
}: {
  label: string
  children: React.ReactNode
}) {
  return (
    <div className="space-y-1.5">
      <Label>{label}</Label>
      {children}
    </div>
  )
}
function SelectField({
  label,
  value,
  onChange,
  items,
}: {
  label: string
  value: string
  onChange: (value: string) => void
  items: Array<{ value: string; label: string }>
}) {
  return (
    <Field label={label}>
      <select
        className={selectClass}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        required
      >
        <option value="" disabled>
          Chọn...
        </option>
        {items.map((item) => (
          <option key={item.value} value={item.value}>
            {item.label}
          </option>
        ))}
      </select>
    </Field>
  )
}
function SubmitButton({
  pending,
  children,
}: {
  pending: boolean
  children: React.ReactNode
}) {
  return (
    <Button type="submit" disabled={pending}>
      {pending ? (
        <Loader2 className="size-4 animate-spin" />
      ) : (
        <Plus className="size-4" />
      )}
      {children}
    </Button>
  )
}
function showError(error: Error) {
  toast.error(error.message || 'Không thể lưu dữ liệu')
}
function relationshipLabel(value: GuardianRelationship) {
  return value === 'MOTHER' ? 'Mẹ' : value === 'FATHER' ? 'Bố' : 'Người giám hộ'
}

function assessmentLabel(type: string, sequenceNumber: number) {
  if (type === 'REGULAR') return `Thường xuyên ${sequenceNumber}`
  return type === 'MIDTERM' ? 'Giữa kỳ' : 'Cuối kỳ'
}
