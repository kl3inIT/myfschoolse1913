package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.time.LocalTime;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationType;

public record CreateParentApplicationRequest(
    @NotNull StudentApplicationType type,
    @NotNull LocalDate startDate,
    LocalDate endDate,
    LocalTime requestedTime,
    @NotBlank @Size(max = 200) String reason,
    @Size(max = 1000) String details) {}
