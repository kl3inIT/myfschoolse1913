package vn.edu.fpt.myfschoolse1913.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PasswordResetConfirmRequest(
		@NotBlank(message = "Phiên đổi mật khẩu không hợp lệ")
		String resetToken,

		@NotBlank(message = "Vui lòng nhập mật khẩu mới")
		@Size(min = 8, max = 72, message = "Mật khẩu mới phải từ 8 đến 72 ký tự")
		String newPassword
) {
}
