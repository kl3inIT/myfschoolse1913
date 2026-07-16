package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateParentRequest(
    @NotBlank String phoneNumber,
    @NotBlank @Size(max = 120) String fullName,
    @NotBlank @Size(min = 8, max = 100) String initialPassword) {}
