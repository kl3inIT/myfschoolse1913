package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.UUID;

public record HomeroomAssignmentRequest(
    @NotNull UUID teacherId,
    @NotNull UUID classId,
    @NotNull UUID academicYearId,
    LocalDate startsOn,
    LocalDate endsOn,
    boolean active) {}
