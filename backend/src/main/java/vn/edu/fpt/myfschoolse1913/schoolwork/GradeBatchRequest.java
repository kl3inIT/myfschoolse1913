package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record GradeBatchRequest(
    @NotNull AssessmentType type,
    @Min(1) @Max(4) int sequenceNumber,
    @NotNull @Size(min = 1, max = 120) String title,
    boolean published,
    @NotEmpty List<@Valid Entry> entries) {
  public record Entry(
      @NotNull UUID studentId,
      @DecimalMin("0.0") @DecimalMax("10.0") BigDecimal score,
      @Size(max = 255) String comment) {}
}
