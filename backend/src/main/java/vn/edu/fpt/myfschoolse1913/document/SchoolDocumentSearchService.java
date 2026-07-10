package vn.edu.fpt.myfschoolse1913.document;

import java.util.List;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;

/**
 * Semantic search over the admin-managed school documents. Public module API —
 * this is what the assistant's search tool calls to ground answers about
 * regulations, school info, and subject learning materials.
 */
@Service
public class SchoolDocumentSearchService {

	private final VectorStore vectorStore;

	SchoolDocumentSearchService(VectorStore vectorStore) {
		this.vectorStore = vectorStore;
	}

	public List<DocumentSnippet> search(String query, int topK, Double similarityThreshold) {
		if (query == null || query.isBlank()) {
			return List.of();
		}

		var request = SearchRequest.builder()
				.query(query.strip())
				.topK(Math.clamp(topK, 1, 20));
		if (similarityThreshold != null) {
			request.similarityThreshold(similarityThreshold);
		}
		List<Document> chunks = vectorStore.similaritySearch(request.build());

		return chunks.stream()
				.map((chunk) -> new DocumentSnippet(
						stringMetadata(chunk, SchoolDocumentIngestionService.METADATA_TITLE),
						stringMetadata(chunk, SchoolDocumentIngestionService.METADATA_CATEGORY),
						stringMetadata(chunk, SchoolDocumentIngestionService.METADATA_SUBJECT_NAME),
						chunk.getText()
				))
				.toList();
	}

	private String stringMetadata(Document chunk, String key) {
		Object value = chunk.getMetadata().get(key);
		return value == null ? null : String.valueOf(value);
	}

	public record DocumentSnippet(
			String documentTitle,
			String category,
			String subjectName,
			String excerpt
	) {
	}
}
