package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;

public record AdminGradeImportResponse(
		int totalRows,
		int createdGrades,
		int updatedGrades,
		int skippedRows,
		List<RowResult> rows
) {

	public record RowResult(
			int rowNumber,
			String studentCode,
			String subjectCode,
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
