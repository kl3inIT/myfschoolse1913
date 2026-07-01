package vn.edu.fpt.myfschoolse1913.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record PasswordResetVerifyRequest(
		@NotBlank
		@Pattern(regexp = "^[0-9]{9,15}$", message = "phoneNumber must contain 9 to 15 digits")
		String phoneNumber,

		@NotBlank
		@Pattern(regexp = "^[0-9]{6}$", message = "otp must contain 6 digits")
		String otp
) {
}
