package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus;

public record TeacherApplicationReviewRequest(
    @NotNull StudentApplicationStatus status, @NotBlank @Size(max = 500) String reviewerNote) {}
