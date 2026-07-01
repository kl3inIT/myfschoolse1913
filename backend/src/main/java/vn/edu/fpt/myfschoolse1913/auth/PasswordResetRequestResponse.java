package vn.edu.fpt.myfschoolse1913.auth;

public record PasswordResetRequestResponse(
		String message,
		String debugOtp
) {

	public static PasswordResetRequestResponse accepted(String debugOtp) {
		return new PasswordResetRequestResponse(
				"Nếu số điện thoại hợp lệ, mã xác thực sẽ được gửi trong ít phút.",
				debugOtp
		);
	}
}
