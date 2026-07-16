package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationType;

public record TeacherApplicationsResponse(String className, List<Item> applications) {
  public record Item(
      UUID id,
      UUID studentId,
      String studentCode,
      String studentName,
      StudentApplicationType type,
      StudentApplicationStatus status,
      LocalDate startDate,
      LocalDate endDate,
      LocalTime requestedTime,
      String reason,
      String details,
      String reviewerNote,
      Instant createdAt) {}
}
