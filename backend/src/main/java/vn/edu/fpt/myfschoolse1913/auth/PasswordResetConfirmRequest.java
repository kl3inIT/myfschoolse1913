package vn.edu.fpt.myfschoolse1913.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PasswordResetConfirmRequest(
		@NotBlank
		String resetToken,

		@NotBlank
		@Size(min = 8, max = 72, message = "newPassword must contain 8 to 72 characters")
		String newPassword
) {
}
