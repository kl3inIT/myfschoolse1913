package vn.edu.fpt.myfschoolse1913.event;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record StudentEventsResponse(
		EventItem featuredEvent,
		List<EventItem> events
) {

	public record EventItem(
			UUID id,
			String title,
			String description,
			String location,
			Instant startsAt,
			Instant endsAt,
			String status
	) {
	}
}
