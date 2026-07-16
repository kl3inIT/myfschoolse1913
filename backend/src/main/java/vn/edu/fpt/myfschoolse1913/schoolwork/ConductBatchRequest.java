package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;
import java.util.UUID;

public record ConductBatchRequest(
    @NotNull UUID semesterId, boolean published, @NotEmpty List<@Valid Entry> entries) {
  public record Entry(
      @NotNull UUID studentId, @NotNull ConductLevel level, @Size(max = 500) String comment) {}
}
