package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record AttendanceBatchRequest(
    @NotNull LocalDate date, @Min(1) int lessonNumber, @NotEmpty List<@Valid Entry> entries) {
  public record Entry(
      @NotNull UUID studentId, @NotNull AttendanceStatus status, @Size(max = 255) String note) {}
}
