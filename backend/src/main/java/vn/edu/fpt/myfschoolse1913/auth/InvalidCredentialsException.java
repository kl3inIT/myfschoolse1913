package vn.edu.fpt.myfschoolse1913.auth;

import vn.edu.fpt.myfschoolse1913.shared.UnauthorizedException;

public class InvalidCredentialsException extends UnauthorizedException {

	public InvalidCredentialsException() {
		this("Thông tin xác thực không hợp lệ");
	}

	public InvalidCredentialsException(String message) {
		super(message);
	}
}
