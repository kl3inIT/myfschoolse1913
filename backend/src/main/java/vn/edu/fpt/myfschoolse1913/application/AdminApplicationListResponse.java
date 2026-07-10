package vn.edu.fpt.myfschoolse1913.application;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public record AdminApplicationListResponse(
		int page,
		int size,
		long totalItems,
		int totalPages,
		List<Item> items
) {

	public record Item(
			UUID id,
			String studentCode,
			String fullName,
			String className,
			String academicYearName,
			String type,
			String status,
			LocalDate targetDate,
			LocalTime requestedTime,
			String reason,
			String details,
			String reviewerNote,
			Instant createdAt,
			Instant reviewedAt
	) {
	}
}
