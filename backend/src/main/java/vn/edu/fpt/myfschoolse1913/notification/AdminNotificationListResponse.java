package vn.edu.fpt.myfschoolse1913.notification;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record AdminNotificationListResponse(
		int page,
		int size,
		long totalItems,
		int totalPages,
		List<Item> items
) {

	public record Item(
			UUID id,
			String title,
			String body,
			SchoolNotificationCategory category,
			SchoolNotificationAudience audience,
			Instant publishedAt,
			boolean pinned,
			boolean active
	) {
	}
}
