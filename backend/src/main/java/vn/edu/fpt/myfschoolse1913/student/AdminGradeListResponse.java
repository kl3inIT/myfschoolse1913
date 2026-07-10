package vn.edu.fpt.myfschoolse1913.student;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record AdminGradeListResponse(
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
			String semesterName,
			String subjectCode,
			String subjectName,
			BigDecimal formativeScore,
			BigDecimal midtermScore,
			BigDecimal finalScore,
			BigDecimal averageScore,
			String teacherComment,
			Instant updatedAt
	) {
	}
}
