package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record AdminSchoolWorkResponse(
    List<TeacherItem> teachers,
    List<ParentItem> parents,
    List<StudentItem> students,
    List<ClassItem> classes,
    List<SemesterItem> semesters,
    List<SubjectItem> subjects,
    List<TeachingAssignmentItem> teachingAssignments,
    List<HomeroomAssignmentItem> homeroomAssignments,
    List<GuardianLinkItem> guardianLinks,
    List<AssessmentItem> publishedAssessments) {
  public record TeacherItem(
      UUID id,
      UUID userId,
      String employeeCode,
      String fullName,
      String phoneNumber,
      String status) {}

  public record ParentItem(
      UUID id, UUID userId, String fullName, String phoneNumber, String status) {}

  public record StudentItem(
      UUID id, String studentCode, String fullName, UUID classId, String className) {}

  public record ClassItem(UUID id, String name, UUID academicYearId, String academicYearName) {}

  public record SemesterItem(UUID id, String name, UUID academicYearId) {}

  public record SubjectItem(UUID id, String code, String name) {}

  public record TeachingAssignmentItem(
      UUID id,
      UUID teacherId,
      String teacherName,
      UUID classId,
      String className,
      UUID subjectId,
      String subjectName,
      UUID semesterId,
      String semesterName,
      TeachingAssignmentType type,
      LocalDate startsOn,
      LocalDate endsOn,
      boolean active) {}

  public record HomeroomAssignmentItem(
      UUID id,
      UUID teacherId,
      String teacherName,
      UUID classId,
      String className,
      UUID academicYearId,
      String academicYearName,
      boolean active) {}

  public record GuardianLinkItem(
      UUID id,
      UUID parentId,
      String parentName,
      UUID studentId,
      String studentName,
      String className,
      GuardianRelationship relationship,
      boolean primaryContact,
      boolean active) {}

  public record AssessmentItem(
      UUID id,
      String studentCode,
      String studentName,
      String className,
      String subjectName,
      String semesterName,
      AssessmentType type,
      int sequenceNumber,
      String title,
      BigDecimal score,
      String comment) {}
}
