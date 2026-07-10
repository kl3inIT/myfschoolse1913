package vn.edu.fpt.myfschoolse1913.document;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record AdminDocumentListResponse(
		int page,
		int size,
		long totalItems,
		int totalPages,
		List<Item> items
) {

	public record Item(
			UUID id,
			String title,
			String category,
			String subjectName,
			String fileName,
			String mimeType,
			long sizeBytes,
			String ingestStatus,
			String ingestError,
			Integer chunkCount,
			Instant updatedAt
	) {

		static Item from(SchoolDocument document) {
			return new Item(
					document.getId(),
					document.getTitle(),
					document.getCategory().name(),
					document.getSubjectName(),
					document.getFileName(),
					document.getMimeType(),
					document.getSizeBytes(),
					document.getIngestStatus().name(),
					document.getIngestError(),
					document.getChunkCount(),
					document.getUpdatedAt()
			);
		}
	}
}
