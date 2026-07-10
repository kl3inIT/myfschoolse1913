package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;

public record AdminTimetableImportResponse(
		int totalRows,
		int createdSlots,
		int updatedSlots,
		int skippedRows,
		List<RowResult> rows
) {

	public enum RowStatus {
		CREATED,
		UPDATED,
		SKIPPED
	}

	public record RowResult(
			int rowNumber,
			String className,
			int dayIndex,
			int lessonNumber,
			RowStatus status,
			String message
	) {
	}
}
