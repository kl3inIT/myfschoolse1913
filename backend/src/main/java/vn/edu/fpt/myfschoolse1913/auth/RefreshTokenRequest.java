package vn.edu.fpt.myfschoolse1913.auth;

import jakarta.validation.constraints.NotBlank;

public record RefreshTokenRequest(
		@NotBlank(message = "Phiên đăng nhập không hợp lệ")
		String refreshToken
) {
}
