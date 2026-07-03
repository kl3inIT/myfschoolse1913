package vn.edu.fpt.myfschoolse1913.shared;

import jakarta.servlet.http.HttpServletRequest;
import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice
public class ApiExceptionHandler {

	@ExceptionHandler(UnauthorizedException.class)
	ResponseEntity<ApiError> handleUnauthorized(UnauthorizedException exception, HttpServletRequest request) {
		return build(HttpStatus.UNAUTHORIZED, exception.getMessage(), request);
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	ResponseEntity<ApiError> handleValidation(MethodArgumentNotValidException exception, HttpServletRequest request) {
		var message = exception.getBindingResult().getFieldErrors().stream()
				.findFirst()
				.map((error) -> error.getDefaultMessage() == null ? "Dữ liệu không hợp lệ" : error.getDefaultMessage())
				.orElse("Dữ liệu không hợp lệ");
		return build(HttpStatus.BAD_REQUEST, message, request);
	}

	@ExceptionHandler(RateLimitExceededException.class)
	ResponseEntity<ApiError> handleRateLimit(RateLimitExceededException exception, HttpServletRequest request) {
		return build(HttpStatus.TOO_MANY_REQUESTS, exception.getMessage(), request);
	}

	@ExceptionHandler(ResponseStatusException.class)
	ResponseEntity<ApiError> handleResponseStatus(ResponseStatusException exception, HttpServletRequest request) {
		var status = HttpStatus.valueOf(exception.getStatusCode().value());
		var message = exception.getReason() == null ? status.getReasonPhrase() : exception.getReason();
		return build(status, message, request);
	}

	private ResponseEntity<ApiError> build(HttpStatus status, String message, HttpServletRequest request) {
		return ResponseEntity.status(status).body(new ApiError(
				Instant.now(),
				status.value(),
				reasonPhrase(status),
				message,
				request.getRequestURI()
		));
	}

	private String reasonPhrase(HttpStatus status) {
		return switch (status) {
			case BAD_REQUEST -> "Yêu cầu không hợp lệ";
			case NOT_FOUND -> "Không tìm thấy";
			case UNAUTHORIZED -> "Không được phép";
			case TOO_MANY_REQUESTS -> "Quá nhiều yêu cầu";
			default -> status.getReasonPhrase();
		};
	}
}
