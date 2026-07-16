package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationType;

public record ParentWorkspaceResponse(List<ChildItem> children, ChildDetails selectedChild) {
  public record ChildItem(
      UUID id,
      String studentCode,
      String fullName,
      String className,
      GuardianRelationship relationship,
      boolean primaryContact) {}

  public record ChildDetails(
      ChildItem child,
      String academicYear,
      String semester,
      List<ScheduleItem> schedule,
      List<SubjectGradeItem> grades,
      List<AttendanceItem> attendance,
      List<ConductItem> conduct,
      List<ApplicationItem> applications,
      List<NotificationItem> notifications) {}

  public record ScheduleItem(
      int dayIndex,
      int lessonNumber,
      String title,
      String subjectName,
      String roomName,
      String teacherName,
      LocalTime startsAt,
      LocalTime endsAt) {}

  public record SubjectGradeItem(
      UUID subjectId, String subjectName, List<AssessmentItem> assessments, BigDecimal average) {}

  public record AssessmentItem(
      AssessmentType type, int sequenceNumber, String title, BigDecimal score, String comment) {}

  public record AttendanceItem(
      LocalDate date, int lessonNumber, String subjectName, AttendanceStatus status, String note) {}

  public record ConductItem(String semesterName, ConductLevel level, String comment) {}

  public record ApplicationItem(
      UUID id,
      StudentApplicationType type,
      StudentApplicationStatus status,
      LocalDate startDate,
      LocalDate endDate,
      LocalTime requestedTime,
      String reason,
      String reviewerNote,
      Instant createdAt) {}

  public record NotificationItem(
      UUID id, String title, String body, String category, Instant publishedAt, boolean pinned) {}
}
