import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useEffect, useState } from 'react'
import { toast } from 'sonner'
import {
  BookOpenCheck,
  ClipboardCheck,
  Loader2,
  Save,
  Users,
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
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  fetchTeacherApplications,
  fetchTeacherClassroom,
  fetchTeacherWorkspace,
  reviewTeacherApplication,
  saveAttendance,
  saveConduct,
  saveGrades,
  type AssessmentType,
  type AttendanceStatus,
  type TeacherClassroom,
  type TeacherWorkspace,
} from '@/lib/school-work'

const selectClass =
  'h-9 rounded-md border border-input bg-transparent px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50'
const today = new Date().toISOString().slice(0, 10)

export function TeacherWorkspacePage() {
  const workspaceQuery = useQuery({
    queryKey: ['teacher-workspace'],
    queryFn: fetchTeacherWorkspace,
  })
  const [assignmentId, setAssignmentId] = useState('')
  const [date, setDate] = useState(today)
  const [lessonNumber, setLessonNumber] = useState(1)
  const workspace = workspaceQuery.data
  const selectedId = workspace?.teachingAssignments.some(
    (item) => item.id === assignmentId,
  )
    ? assignmentId
    : (workspace?.teachingAssignments[0]?.id ?? '')
  const classroomQuery = useQuery({
    queryKey: ['teacher-classroom', selectedId, date, lessonNumber],
    queryFn: () => fetchTeacherClassroom(selectedId, date, lessonNumber),
    enabled: Boolean(selectedId),
  })

  if (workspaceQuery.isPending) return <Skeleton className="h-[520px]" />
  if (!workspace)
    return (
      <p className="text-sm text-destructive">
        Không tải được không gian giáo viên.
      </p>
    )

  return (
    <div className="space-y-6">
      <TeacherSummary workspace={workspace} />
      {workspace.teachingAssignments.length === 0 ? (
        <Card>
          <CardHeader>
            <CardTitle>Chưa có phân công</CardTitle>
            <CardDescription>
              Quản trị viên cần gán lớp, môn và học kỳ trước khi giáo viên thao
              tác.
            </CardDescription>
          </CardHeader>
        </Card>
      ) : (
        <>
          <Card>
            <CardContent className="flex flex-wrap items-end gap-3 pt-6">
              <div className="min-w-64 flex-1 space-y-1.5">
                <Label>Phân công đang làm việc</Label>
                <select
                  className={`${selectClass} w-full`}
                  value={selectedId}
                  onChange={(event) => setAssignmentId(event.target.value)}
                >
                  {workspace.teachingAssignments.map((item) => (
                    <option key={item.id} value={item.id}>
                      {item.className} · {item.subjectName} ·{' '}
                      {item.semesterName}
                    </option>
                  ))}
                </select>
              </div>
              <div className="space-y-1.5">
                <Label>Ngày điểm danh</Label>
                <Input
                  type="date"
                  value={date}
                  onChange={(event) => setDate(event.target.value)}
                />
              </div>
              <div className="space-y-1.5">
                <Label>Tiết</Label>
                <Input
                  className="w-20"
                  type="number"
                  min={1}
                  value={lessonNumber}
                  onChange={(event) =>
                    setLessonNumber(Number(event.target.value))
                  }
                />
              </div>
            </CardContent>
          </Card>
          {classroomQuery.isPending ? (
            <Skeleton className="h-96" />
          ) : classroomQuery.data ? (
            <ClassroomPanels
              key={`${selectedId}-${date}-${lessonNumber}`}
              classroom={classroomQuery.data}
            />
          ) : null}
        </>
      )}
      {workspace.homeroomAssignments.map((homeroom) => (
        <HomeroomPanel
          key={homeroom.id}
          workspace={workspace}
          classId={homeroom.classId}
          className={homeroom.className}
        />
      ))}
    </div>
  )
}

function TeacherSummary({ workspace }: { workspace: TeacherWorkspace }) {
  return (
    <section className="grid gap-4 md:grid-cols-3">
      <Card>
        <CardHeader>
          <CardDescription>Giáo viên</CardDescription>
          <CardTitle className="text-xl">{workspace.fullName}</CardTitle>
        </CardHeader>
        <CardContent>
          <Badge variant="secondary">{workspace.employeeCode}</Badge>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <CardDescription>Phân công bộ môn</CardDescription>
          <CardTitle className="text-3xl tabular-nums">
            {workspace.teachingAssignments.length}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-xs text-muted-foreground">
            Chỉ các lớp và môn đang hiệu lực
          </p>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <CardDescription>Lớp chủ nhiệm</CardDescription>
          <CardTitle className="text-3xl tabular-nums">
            {workspace.homeroomAssignments.length}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-xs text-muted-foreground">
            Duyệt đơn ngắn hạn và rèn luyện
          </p>
        </CardContent>
      </Card>
    </section>
  )
}

function ClassroomPanels({ classroom }: { classroom: TeacherClassroom }) {
  return (
    <div className="grid gap-4 2xl:grid-cols-2">
      <AttendancePanel classroom={classroom} />
      <GradePanel classroom={classroom} />
    </div>
  )
}

function AttendancePanel({ classroom }: { classroom: TeacherClassroom }) {
  const queryClient = useQueryClient()
  const [statuses, setStatuses] = useState<Record<string, AttendanceStatus>>(
    () =>
      Object.fromEntries(
        classroom.students.map((student) => [
          student.studentId,
          student.attendanceStatus ?? 'PRESENT',
        ]),
      ),
  )
  const mutation = useMutation({
    mutationFn: () =>
      saveAttendance(classroom.assignmentId, {
        date: classroom.attendanceDate,
        lessonNumber: classroom.lessonNumber,
        entries: classroom.students.map((student) => ({
          studentId: student.studentId,
          status: statuses[student.studentId] ?? 'PRESENT',
        })),
      }),
    onSuccess: () => {
      toast.success('Đã lưu điểm danh')
      void queryClient.invalidateQueries({ queryKey: ['teacher-classroom'] })
    },
    onError: showError,
  })
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-base">
          <ClipboardCheck className="size-4" />
          Điểm danh · tiết {classroom.lessonNumber}
        </CardTitle>
        <CardDescription>
          {classroom.className} · {formatDate(classroom.attendanceDate)}. Mặc
          định có mặt, chỉ đổi các trường hợp ngoại lệ.
        </CardDescription>
      </CardHeader>
      <CardContent className="px-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Học sinh</TableHead>
              <TableHead className="w-52">Trạng thái</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {classroom.students.map((student) => (
              <TableRow key={student.studentId}>
                <TableCell>
                  <p className="font-medium">{student.fullName}</p>
                  <p className="text-xs text-muted-foreground">
                    {student.studentCode}
                  </p>
                </TableCell>
                <TableCell>
                  <select
                    className={`${selectClass} w-full`}
                    value={statuses[student.studentId]}
                    onChange={(event) =>
                      setStatuses((current) => ({
                        ...current,
                        [student.studentId]: event.target
                          .value as AttendanceStatus,
                      }))
                    }
                  >
                    <option value="PRESENT">Có mặt</option>
                    <option value="ABSENT_EXCUSED">Vắng có phép</option>
                    <option value="ABSENT_UNEXCUSED">Vắng không phép</option>
                    <option value="LATE">Đi muộn</option>
                    <option value="EARLY_LEAVE">Về sớm</option>
                  </select>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <div className="flex justify-end border-t p-4">
          <Button
            onClick={() => mutation.mutate()}
            disabled={mutation.isPending}
          >
            {mutation.isPending ? (
              <Loader2 className="size-4 animate-spin" />
            ) : (
              <Save className="size-4" />
            )}
            Lưu điểm danh
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}

function GradePanel({ classroom }: { classroom: TeacherClassroom }) {
  const queryClient = useQueryClient()
  const [type, setType] = useState<AssessmentType>('REGULAR')
  const [sequenceNumber, setSequenceNumber] = useState(3)
  const [title, setTitle] = useState('Kiểm tra thường xuyên 3')
  const [published, setPublished] = useState(false)
  const [scores, setScores] = useState<Record<string, string>>({})
  useEffect(() => {
    setScores(
      Object.fromEntries(
        classroom.students.map((student) => {
          const result = student.assessments.find(
            (item) =>
              item.type === type && item.sequenceNumber === sequenceNumber,
          )
          return [student.studentId, result?.score?.toString() ?? '']
        }),
      ),
    )
  }, [classroom, type, sequenceNumber])
  const mutation = useMutation({
    mutationFn: () =>
      saveGrades(classroom.assignmentId, {
        type,
        sequenceNumber,
        title,
        published,
        entries: classroom.students.map((student) => ({
          studentId: student.studentId,
          score:
            scores[student.studentId] === ''
              ? null
              : Number(scores[student.studentId]),
        })),
      }),
    onSuccess: () => {
      toast.success(published ? 'Đã nhập và công bố điểm' : 'Đã lưu điểm nháp')
      void queryClient.invalidateQueries({ queryKey: ['teacher-classroom'] })
    },
    onError: showError,
  })
  function changeType(next: AssessmentType) {
    setType(next)
    setSequenceNumber(next === 'REGULAR' ? 3 : 1)
    setTitle(
      next === 'REGULAR'
        ? 'Kiểm tra thường xuyên 3'
        : next === 'MIDTERM'
          ? 'Kiểm tra giữa kỳ'
          : 'Kiểm tra cuối kỳ',
    )
  }
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-base">
          <BookOpenCheck className="size-4" />
          Sổ điểm · {classroom.subjectName}
        </CardTitle>
        <CardDescription>
          Nhiều điểm thường xuyên, một giữa kỳ và một cuối kỳ. Điểm trung bình
          được tính tự động.
        </CardDescription>
      </CardHeader>
      <CardContent className="px-0">
        <div className="grid gap-3 border-b px-4 pb-4 sm:grid-cols-3">
          <div className="space-y-1.5">
            <Label>Loại đầu điểm</Label>
            <select
              className={`${selectClass} w-full`}
              value={type}
              onChange={(event) =>
                changeType(event.target.value as AssessmentType)
              }
            >
              <option value="REGULAR">Thường xuyên</option>
              <option value="MIDTERM">Giữa kỳ</option>
              <option value="FINAL">Cuối kỳ</option>
            </select>
          </div>
          <div className="space-y-1.5">
            <Label>Lần</Label>
            <Input
              type="number"
              min={1}
              max={type === 'REGULAR' ? 4 : 1}
              value={sequenceNumber}
              disabled={type !== 'REGULAR'}
              onChange={(event) =>
                setSequenceNumber(Number(event.target.value))
              }
            />
          </div>
          <div className="space-y-1.5">
            <Label>Tên đầu điểm</Label>
            <Input
              value={title}
              onChange={(event) => setTitle(event.target.value)}
            />
          </div>
        </div>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Học sinh</TableHead>
              <TableHead className="w-24">Điểm</TableHead>
              <TableHead className="w-24">TB HK</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {classroom.students.map((student) => (
              <TableRow key={student.studentId}>
                <TableCell>
                  <p className="font-medium">{student.fullName}</p>
                  <p className="text-xs text-muted-foreground">
                    {student.studentCode}
                  </p>
                </TableCell>
                <TableCell>
                  <Input
                    aria-label={`Điểm ${student.fullName}`}
                    type="number"
                    min={0}
                    max={10}
                    step={0.1}
                    value={scores[student.studentId] ?? ''}
                    onChange={(event) =>
                      setScores((current) => ({
                        ...current,
                        [student.studentId]: event.target.value,
                      }))
                    }
                  />
                </TableCell>
                <TableCell className="font-semibold tabular-nums">
                  {student.semesterAverage ?? '—'}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <div className="flex flex-wrap items-center justify-between gap-3 border-t p-4">
          <div className="flex items-center gap-2">
            <Checkbox
              id="publish-grade"
              checked={published}
              onCheckedChange={(value) => setPublished(value === true)}
            />
            <Label htmlFor="publish-grade">
              Công bố cho học sinh và phụ huynh
            </Label>
          </div>
          <Button
            onClick={() => mutation.mutate()}
            disabled={mutation.isPending}
          >
            {mutation.isPending ? (
              <Loader2 className="size-4 animate-spin" />
            ) : (
              <Save className="size-4" />
            )}
            Lưu sổ điểm
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}

function HomeroomPanel({
  workspace,
  classId,
  className,
}: {
  workspace: TeacherWorkspace
  classId: string
  className: string
}) {
  const queryClient = useQueryClient()
  const applicationsQuery = useQuery({
    queryKey: ['teacher-applications', classId],
    queryFn: () => fetchTeacherApplications(classId),
  })
  const review = useMutation({
    mutationFn: ({
      id,
      status,
    }: {
      id: string
      status: 'APPROVED' | 'REJECTED'
    }) =>
      reviewTeacherApplication(
        classId,
        id,
        status,
        status === 'APPROVED'
          ? 'Giáo viên chủ nhiệm đã xác nhận'
          : 'Thông tin chưa đủ để xác nhận',
      ),
    onSuccess: () => {
      toast.success('Đã cập nhật đơn')
      void queryClient.invalidateQueries({
        queryKey: ['teacher-applications', classId],
      })
    },
    onError: showError,
  })
  const assignment = workspace.teachingAssignments.find(
    (item) => item.classId === classId,
  )
  const classroomQuery = useQuery({
    queryKey: ['teacher-homeroom-roster', assignment?.id],
    queryFn: () => fetchTeacherClassroom(assignment!.id, today, 1),
    enabled: Boolean(assignment),
  })
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-base">
          <Users className="size-4" />
          Công tác chủ nhiệm · {className}
        </CardTitle>
        <CardDescription>
          Duyệt đơn nghỉ tối đa 3 ngày; đơn giấy tờ và trường hợp dài hơn chuyển
          quản trị viên.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {assignment && classroomQuery.data ? (
          <ConductEditor
            classId={classId}
            semesterId={assignment.semesterId}
            classroom={classroomQuery.data}
          />
        ) : (
          <p className="text-sm text-muted-foreground">
            Cần có ít nhất một phân công bộ môn trong lớp để tải danh sách đánh
            giá rèn luyện.
          </p>
        )}

        {applicationsQuery.isPending ? (
          <Skeleton className="h-40" />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Học sinh</TableHead>
                <TableHead>Đơn</TableHead>
                <TableHead>Ngày</TableHead>
                <TableHead>Trạng thái</TableHead>
                <TableHead className="text-right">Xử lý</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {applicationsQuery.data?.applications.map((item) => (
                <TableRow key={item.id}>
                  <TableCell>
                    <p className="font-medium">{item.studentName}</p>
                    <p className="text-xs text-muted-foreground">
                      {item.studentCode}
                    </p>
                  </TableCell>
                  <TableCell>
                    {applicationTypeLabel(item.type)}
                    <p className="max-w-72 truncate text-xs text-muted-foreground">
                      {item.reason}
                    </p>
                  </TableCell>
                  <TableCell>
                    {formatDate(item.startDate)}
                    {item.endDate !== item.startDate
                      ? ` – ${formatDate(item.endDate)}`
                      : ''}
                  </TableCell>
                  <TableCell>
                    <Badge
                      variant={
                        item.status === 'PENDING'
                          ? 'secondary'
                          : item.status === 'APPROVED'
                            ? 'default'
                            : 'destructive'
                      }
                    >
                      {statusLabel(item.status)}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-right">
                    {item.status === 'PENDING' &&
                    item.type !== 'DOCUMENT_REQUEST' ? (
                      <div className="flex justify-end gap-2">
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() =>
                            review.mutate({
                              id: item.id,
                              status: 'REJECTED',
                            })
                          }
                        >
                          Từ chối
                        </Button>
                        <Button
                          size="sm"
                          onClick={() =>
                            review.mutate({
                              id: item.id,
                              status: 'APPROVED',
                            })
                          }
                        >
                          Duyệt
                        </Button>
                      </div>
                    ) : (
                      <span className="text-xs text-muted-foreground">
                        {item.reviewerNote ?? '—'}
                      </span>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </CardContent>
    </Card>
  )
}

type ConductLevel = 'GOOD' | 'FAIR' | 'PASS' | 'NOT_PASS'

function ConductEditor({
  classId,
  semesterId,
  classroom,
}: {
  classId: string
  semesterId: string
  classroom: TeacherClassroom
}) {
  const [levels, setLevels] = useState<Record<string, ConductLevel>>(() =>
    Object.fromEntries(
      classroom.students.map((student) => [student.studentId, 'GOOD']),
    ),
  )
  const [comments, setComments] = useState<Record<string, string>>({})
  const [published, setPublished] = useState(false)
  const mutation = useMutation({
    mutationFn: () =>
      saveConduct(classId, {
        semesterId,
        published,
        entries: classroom.students.map((student) => ({
          studentId: student.studentId,
          level: levels[student.studentId] ?? 'GOOD',
          comment: comments[student.studentId]?.trim() || undefined,
        })),
      }),
    onSuccess: () =>
      toast.success(
        published
          ? 'Đã lưu và công bố đánh giá rèn luyện'
          : 'Đã lưu đánh giá rèn luyện nháp',
      ),
    onError: showError,
  })

  return (
    <details className="rounded-md border">
      <summary className="cursor-pointer px-4 py-3 text-sm font-semibold">
        Đánh giá rèn luyện học kỳ
      </summary>
      <div className="border-t">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Học sinh</TableHead>
              <TableHead className="w-48">Mức rèn luyện</TableHead>
              <TableHead>Nhận xét</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {classroom.students.map((student) => (
              <TableRow key={student.studentId}>
                <TableCell>
                  <p className="font-medium">{student.fullName}</p>
                  <p className="text-xs text-muted-foreground">
                    {student.studentCode}
                  </p>
                </TableCell>
                <TableCell>
                  <select
                    className={`${selectClass} w-full`}
                    value={levels[student.studentId] ?? 'GOOD'}
                    onChange={(event) =>
                      setLevels((current) => ({
                        ...current,
                        [student.studentId]: event.target.value as ConductLevel,
                      }))
                    }
                  >
                    <option value="GOOD">Tốt</option>
                    <option value="FAIR">Khá</option>
                    <option value="PASS">Đạt</option>
                    <option value="NOT_PASS">Chưa đạt</option>
                  </select>
                </TableCell>
                <TableCell>
                  <Input
                    value={comments[student.studentId] ?? ''}
                    placeholder="Nhận xét riêng cho học sinh"
                    onChange={(event) =>
                      setComments((current) => ({
                        ...current,
                        [student.studentId]: event.target.value,
                      }))
                    }
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <div className="flex flex-wrap items-center justify-between gap-3 border-t p-4">
          <div className="flex items-center gap-2">
            <Checkbox
              id={`publish-conduct-${classId}`}
              checked={published}
              onCheckedChange={(value) => setPublished(value === true)}
            />
            <Label htmlFor={`publish-conduct-${classId}`}>
              Công bố cho học sinh và phụ huynh
            </Label>
          </div>
          <Button
            type="button"
            disabled={mutation.isPending}
            onClick={() => mutation.mutate()}
          >
            {mutation.isPending ? (
              <Loader2 className="size-4 animate-spin" />
            ) : (
              <Save className="size-4" />
            )}
            Lưu rèn luyện
          </Button>
        </div>
      </div>
    </details>
  )
}

function formatDate(value: string) {
  return new Date(`${value}T00:00:00`).toLocaleDateString('vi-VN')
}
function statusLabel(value: string) {
  return value === 'PENDING'
    ? 'Chờ duyệt'
    : value === 'APPROVED'
      ? 'Đã duyệt'
      : 'Từ chối'
}
function applicationTypeLabel(value: string) {
  return value === 'ABSENCE'
    ? 'Xin nghỉ'
    : value === 'LATE_ARRIVAL'
      ? 'Đi muộn'
      : value === 'DOCUMENT_REQUEST'
        ? 'Giấy tờ'
        : 'Về sớm'
}
function showError(error: Error) {
  toast.error(error.message || 'Không thể lưu dữ liệu')
}
