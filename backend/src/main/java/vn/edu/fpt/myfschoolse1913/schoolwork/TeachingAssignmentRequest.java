package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.UUID;

public record TeachingAssignmentRequest(
    @NotNull UUID teacherId,
    @NotNull UUID classId,
    @NotNull UUID subjectId,
    @NotNull UUID semesterId,
    @NotNull TeachingAssignmentType type,
    LocalDate startsOn,
    LocalDate endsOn,
    boolean active) {}
