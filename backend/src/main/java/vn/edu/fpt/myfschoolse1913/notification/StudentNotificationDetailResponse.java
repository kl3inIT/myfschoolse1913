package vn.edu.fpt.myfschoolse1913.notification;

import java.time.Instant;
import java.util.UUID;

public record StudentNotificationDetailResponse(
		UUID id,
		String title,
		String body,
		String category,
		Instant publishedAt,
		boolean pinned,
		boolean read
) {
}
