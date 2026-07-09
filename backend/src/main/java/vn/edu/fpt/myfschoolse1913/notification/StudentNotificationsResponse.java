package vn.edu.fpt.myfschoolse1913.notification;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record StudentNotificationsResponse(
		List<NotificationItem> notifications
) {

	public record NotificationItem(
			UUID id,
			String title,
			String body,
			String category,
			Instant publishedAt,
			boolean pinned,
			boolean read
	) {
	}
}
