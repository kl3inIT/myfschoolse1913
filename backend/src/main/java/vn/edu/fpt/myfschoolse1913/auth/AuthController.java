package vn.edu.fpt.myfschoolse1913.auth;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

	private final AuthService authService;

	public AuthController(AuthService authService) {
		this.authService = authService;
	}

	@PostMapping("/login")
	public AuthResponse login(@Valid @RequestBody LoginRequest request) {
		return authService.login(request);
	}

	@PostMapping("/refresh")
	public AuthResponse refresh(@Valid @RequestBody RefreshTokenRequest request) {
		return authService.refresh(request);
	}

	@PostMapping("/logout")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void logout(@Valid @RequestBody RefreshTokenRequest request) {
		authService.logout(request);
	}

	@PostMapping("/password-reset/request")
	public PasswordResetRequestResponse requestPasswordReset(@Valid @RequestBody PasswordResetRequest request) {
		return authService.requestPasswordReset(request);
	}

	@PostMapping("/password-reset/verify")
	public PasswordResetVerifyResponse verifyPasswordResetOtp(@Valid @RequestBody PasswordResetVerifyRequest request) {
		return authService.verifyPasswordResetOtp(request);
	}

	@PostMapping("/password-reset/confirm")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void confirmPasswordReset(@Valid @RequestBody PasswordResetConfirmRequest request) {
		authService.confirmPasswordReset(request);
	}
}
