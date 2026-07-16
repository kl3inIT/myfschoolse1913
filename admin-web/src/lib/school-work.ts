import { authorizedJson } from '@/lib/api'

export type TeachingAssignmentType = 'PRIMARY' | 'CO_TEACHER' | 'SUBSTITUTE'
export type GuardianRelationship = 'FATHER' | 'MOTHER' | 'GUARDIAN'
export type AttendanceStatus =
  | 'PRESENT'
  | 'ABSENT_EXCUSED'
  | 'ABSENT_UNEXCUSED'
  | 'LATE'
  | 'EARLY_LEAVE'
export type AssessmentType = 'REGULAR' | 'MIDTERM' | 'FINAL'

export type TeacherItem = {
  id: string
  userId: string
  employeeCode: string
  fullName: string
  phoneNumber: string
  status: string
}
export type ParentItem = {
  id: string
  userId: string
  fullName: string
  phoneNumber: string
  status: string
}
export type StudentItem = {
  id: string
  studentCode: string
  fullName: string
  classId: string
  className: string
}
export type ClassItem = {
  id: string
  name: string
  academicYearId: string
  academicYearName: string
}
export type SemesterItem = { id: string; name: string; academicYearId: string }
export type SubjectItem = { id: string; code: string; name: string }
export type TeachingAssignmentItem = {
  id: string
  teacherId: string
  teacherName: string
  classId: string
  className: string
  subjectId: string
  subjectName: string
  semesterId: string
  semesterName: string
  type: TeachingAssignmentType
  startsOn: string | null
  endsOn: string | null
  active: boolean
}
export type HomeroomAssignmentItem = {
  id: string
  teacherId: string
  teacherName: string
  classId: string
  className: string
  academicYearId: string
  academicYearName: string
  active: boolean
}
export type GuardianLinkItem = {
  id: string
  parentId: string
  parentName: string
  studentId: string
  studentName: string
  className: string
  relationship: GuardianRelationship
  primaryContact: boolean
  active: boolean
}
export type AdminAssessmentItem = {
  id: string
  studentCode: string
  studentName: string
  className: string
  subjectName: string
  semesterName: string
  type: AssessmentType
  sequenceNumber: number
  title: string
  score: number
  comment: string | null
}
export type AdminSchoolWork = {
  teachers: TeacherItem[]
  parents: ParentItem[]
  students: StudentItem[]
  classes: ClassItem[]
  semesters: SemesterItem[]
  subjects: SubjectItem[]
  teachingAssignments: TeachingAssignmentItem[]
  homeroomAssignments: HomeroomAssignmentItem[]
  guardianLinks: GuardianLinkItem[]
  publishedAssessments: AdminAssessmentItem[]
}

export type TeacherWorkspace = {
  teacherId: string
  employeeCode: string
  fullName: string
  teachingAssignments: TeachingAssignmentItem[]
  homeroomAssignments: HomeroomAssignmentItem[]
}
export type AssessmentItem = {
  id: string
  type: AssessmentType
  sequenceNumber: number
  title: string
  score: number | null
  comment: string | null
  published: boolean
}
export type ClassroomStudent = {
  studentId: string
  studentCode: string
  fullName: string
  attendanceStatus: AttendanceStatus | null
  attendanceNote: string | null
  assessments: AssessmentItem[]
  semesterAverage: number | null
}
export type TeacherClassroom = {
  assignmentId: string
  className: string
  subjectName: string
  semesterName: string
  attendanceDate: string
  lessonNumber: number
  students: ClassroomStudent[]
}
export type TeacherApplication = {
  id: string
  studentId: string
  studentCode: string
  studentName: string
  type: string
  status: string
  startDate: string
  endDate: string
  requestedTime: string | null
  reason: string
  details: string | null
  reviewerNote: string | null
  createdAt: string
}
export type TeacherApplications = {
  className: string
  applications: TeacherApplication[]
}

export const fetchAdminSchoolWork = () =>
  authorizedJson<AdminSchoolWork>('/api/admin/school-work')
export const createTeacher = (input: {
  phoneNumber: string
  fullName: string
  employeeCode: string
  initialPassword: string
}) =>
  authorizedJson<TeacherItem>('/api/admin/school-work/teachers', {
    method: 'POST',
    body: JSON.stringify(input),
  })
export const createParent = (input: {
  phoneNumber: string
  fullName: string
  initialPassword: string
}) =>
  authorizedJson<ParentItem>('/api/admin/school-work/parents', {
    method: 'POST',
    body: JSON.stringify(input),
  })
export const assignTeacher = (input: {
  teacherId: string
  classId: string
  subjectId: string
  semesterId: string
  type: TeachingAssignmentType
  startsOn?: string
  endsOn?: string
  active: boolean
}) =>
  authorizedJson<TeachingAssignmentItem>(
    '/api/admin/school-work/teaching-assignments',
    { method: 'POST', body: JSON.stringify(input) },
  )
export const assignHomeroom = (input: {
  teacherId: string
  classId: string
  academicYearId: string
  active: boolean
}) =>
  authorizedJson<HomeroomAssignmentItem>(
    '/api/admin/school-work/homeroom-assignments',
    { method: 'POST', body: JSON.stringify(input) },
  )
export const linkGuardian = (input: {
  parentId: string
  studentId: string
  relationship: GuardianRelationship
  primaryContact: boolean
  active: boolean
}) =>
  authorizedJson<GuardianLinkItem>('/api/admin/school-work/guardian-links', {
    method: 'POST',
    body: JSON.stringify(input),
  })
export const correctPublishedAssessment = (
  resultId: string,
  input: { score: number; comment?: string; reason: string },
) =>
  authorizedJson<AdminAssessmentItem>(
    `/api/admin/school-work/assessment-results/${resultId}/correction`,
    { method: 'POST', body: JSON.stringify(input) },
  )

export const fetchTeacherWorkspace = () =>
  authorizedJson<TeacherWorkspace>('/api/teachers/me/workspace')
export const fetchTeacherClassroom = (
  assignmentId: string,
  date: string,
  lessonNumber: number,
) =>
  authorizedJson<TeacherClassroom>(
    `/api/teachers/me/assignments/${assignmentId}/classroom?date=${date}&lessonNumber=${lessonNumber}`,
  )
export const saveAttendance = (
  assignmentId: string,
  input: {
    date: string
    lessonNumber: number
    entries: Array<{
      studentId: string
      status: AttendanceStatus
      note?: string
    }>
  },
) =>
  authorizedJson<TeacherClassroom>(
    `/api/teachers/me/assignments/${assignmentId}/attendance`,
    { method: 'PUT', body: JSON.stringify(input) },
  )
export const saveGrades = (
  assignmentId: string,
  input: {
    type: AssessmentType
    sequenceNumber: number
    title: string
    published: boolean
    entries: Array<{
      studentId: string
      score: number | null
      comment?: string
    }>
  },
) =>
  authorizedJson<TeacherClassroom>(
    `/api/teachers/me/assignments/${assignmentId}/grades`,
    { method: 'PUT', body: JSON.stringify(input) },
  )
export const fetchTeacherApplications = (classId: string) =>
  authorizedJson<TeacherApplications>(
    `/api/teachers/me/homeroom/${classId}/applications`,
  )
export const reviewTeacherApplication = (
  classId: string,
  applicationId: string,
  status: 'APPROVED' | 'REJECTED',
  reviewerNote: string,
) =>
  authorizedJson<TeacherApplication>(
    `/api/teachers/me/homeroom/${classId}/applications/${applicationId}`,
    { method: 'PUT', body: JSON.stringify({ status, reviewerNote }) },
  )
export const saveConduct = (
  classId: string,
  input: {
    semesterId: string
    published: boolean
    entries: Array<{
      studentId: string
      level: 'GOOD' | 'FAIR' | 'PASS' | 'NOT_PASS'
      comment?: string
    }>
  },
) =>
  authorizedJson<void>(`/api/teachers/me/homeroom/${classId}/conduct`, {
    method: 'PUT',
    body: JSON.stringify(input),
  })
