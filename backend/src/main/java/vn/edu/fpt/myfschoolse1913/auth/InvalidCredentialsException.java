package vn.edu.fpt.myfschoolse1913.auth;

import vn.edu.fpt.myfschoolse1913.shared.UnauthorizedException;

public class InvalidCredentialsException extends UnauthorizedException {

	public InvalidCredentialsException() {
		super("Invalid phone number, password, or refresh token");
	}
}
