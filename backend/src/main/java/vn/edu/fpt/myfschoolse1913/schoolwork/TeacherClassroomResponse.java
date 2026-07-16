package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record TeacherClassroomResponse(
    UUID assignmentId,
    String className,
    String subjectName,
    String semesterName,
    LocalDate attendanceDate,
    int lessonNumber,
    List<StudentRow> students) {
  public record StudentRow(
      UUID studentId,
      String studentCode,
      String fullName,
      AttendanceStatus attendanceStatus,
      String attendanceNote,
      List<AssessmentItem> assessments,
      BigDecimal semesterAverage) {}

  public record AssessmentItem(
      UUID id,
      AssessmentType type,
      int sequenceNumber,
      String title,
      BigDecimal score,
      String comment,
      boolean published) {}
}
