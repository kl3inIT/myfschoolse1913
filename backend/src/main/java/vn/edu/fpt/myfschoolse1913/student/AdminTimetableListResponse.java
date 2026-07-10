package vn.edu.fpt.myfschoolse1913.student;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record AdminTimetableListResponse(
		int page,
		int size,
		long totalItems,
		int totalPages,
		List<Item> items
) {

	public record Item(
			UUID id,
			String className,
			String academicYearName,
			String semesterName,
			int dayIndex,
			int lessonNumber,
			String slotType,
			String title,
			String subjectCode,
			String roomName,
			String teacherName,
			String startsAt,
			String endsAt,
			Instant updatedAt
	) {
	}
}
