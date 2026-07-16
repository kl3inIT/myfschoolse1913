package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record AdminAssessmentCorrectionRequest(
    @NotNull @DecimalMin("0.0") @DecimalMax("10.0") BigDecimal score,
    @Size(max = 255) String comment,
    @NotBlank @Size(max = 500) String reason) {}
