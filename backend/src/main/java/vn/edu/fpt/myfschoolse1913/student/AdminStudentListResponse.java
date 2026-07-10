package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.UUID;

public record AdminStudentListResponse(
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
			String phoneNumber,
			String className,
			String academicYearName,
			String status,
			boolean accountEnabled
	) {
	}
}
