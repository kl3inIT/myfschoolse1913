package vn.edu.fpt.myfschoolse1913.shared;

import java.time.Instant;

public record ApiError(
		Instant timestamp,
		int status,
		String error,
		String message,
		String path
) {
}
