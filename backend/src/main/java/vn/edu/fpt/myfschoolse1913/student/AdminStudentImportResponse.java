package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;

public record AdminStudentImportResponse(
		int totalRows,
		int createdUsers,
		int createdStudents,
		int updatedStudents,
		int skippedRows,
		List<RowResult> rows
) {

	public record RowResult(
			int rowNumber,
			String phoneNumber,
			String studentCode,
			RowStatus status,
			String message
	) {
	}

	public enum RowStatus {
		CREATED,
		UPDATED,
		SKIPPED
	}
}
