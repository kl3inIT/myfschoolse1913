package vn.edu.fpt.myfschoolse1913.application;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public record StudentApplicationsResponse(
		List<ApplicationItem> applications
) {

	public record ApplicationItem(
			UUID id,
			String type,
			String status,
			String title,
			String summary,
			LocalDate targetDate,
			LocalTime requestedTime,
			Instant createdAt
	) {
	}
}
