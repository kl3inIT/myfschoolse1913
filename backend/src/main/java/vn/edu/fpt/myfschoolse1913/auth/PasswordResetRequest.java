package vn.edu.fpt.myfschoolse1913.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record PasswordResetRequest(
		@NotBlank(message = "Vui lòng nhập số điện thoại")
		@Pattern(regexp = "^[0-9]{9,15}$", message = "Số điện thoại phải gồm 9 đến 15 chữ số")
		String phoneNumber
) {
}
