package vn.edu.fpt.myfschoolse1913.document;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.document.Document;
import org.springframework.ai.reader.tika.TikaDocumentReader;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.filter.FilterExpressionBuilder;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.stereotype.Service;

/**
 * Turns an uploaded school document into searchable embedding chunks in the
 * vector store. Chunks carry {documentId, title, category, subjectName}
 * metadata; vector rows are derived and disposable — this service is the only
 * thing that adds or removes them for a document.
 */
@Service
public class SchoolDocumentIngestionService {

	private static final Logger log = LoggerFactory.getLogger(SchoolDocumentIngestionService.class);

	static final String METADATA_DOCUMENT_ID = "documentId";
	static final String METADATA_TITLE = "title";
	static final String METADATA_CATEGORY = "category";
	static final String METADATA_SUBJECT_NAME = "subjectName";

	private final VectorStore vectorStore;
	private final TokenTextSplitter splitter = TokenTextSplitter.builder().build();

	SchoolDocumentIngestionService(VectorStore vectorStore) {
		this.vectorStore = vectorStore;
	}

	/** Replaces the document's chunks in the vector store; returns the chunk count. */
	public int ingest(SchoolDocument document) {
		String text = extractText(document);
		if (text == null || text.isBlank()) {
			throw new IllegalArgumentException(
					"Không đọc được nội dung văn bản từ file. Hỗ trợ PDF, Word, text/Markdown.");
		}

		Map<String, Object> metadata = new HashMap<>();
		metadata.put(METADATA_DOCUMENT_ID, document.getId().toString());
		metadata.put(METADATA_TITLE, document.getTitle());
		metadata.put(METADATA_CATEGORY, document.getCategory().name());
		if (document.getSubjectName() != null && !document.getSubjectName().isBlank()) {
			metadata.put(METADATA_SUBJECT_NAME, document.getSubjectName());
		}

		List<Document> chunks = splitter.apply(List.of(new Document(text, metadata)));

		remove(document.getId());
		vectorStore.add(chunks);
		log.info("Embedded document {} ({}) as {} chunk(s)",
				document.getId(), document.getTitle(), chunks.size());
		return chunks.size();
	}

	/** Drops a document's vectors — vector_store has no FK, cleanup is ours. */
	public void remove(UUID documentId) {
		vectorStore.delete(new FilterExpressionBuilder()
				.eq(METADATA_DOCUMENT_ID, documentId.toString())
				.build());
	}

	private String extractText(SchoolDocument document) {
		String mime = document.getMimeType().toLowerCase(Locale.ROOT);
		String filename = document.getFileName().toLowerCase(Locale.ROOT);
		if (mime.startsWith("text/") || filename.endsWith(".md") || filename.endsWith(".txt")) {
			return new String(document.getContent(), StandardCharsets.UTF_8);
		}

		boolean tikaExtractable = mime.equals("application/pdf")
				|| mime.equals("application/msword")
				|| mime.equals("application/rtf")
				|| mime.contains("officedocument");
		if (!tikaExtractable) {
			return null;
		}

		ByteArrayResource resource = new ByteArrayResource(document.getContent()) {
			@Override
			public String getFilename() {
				return document.getFileName(); // helps Tika's type detection
			}
		};
		return new TikaDocumentReader(resource).get().stream()
				.map(Document::getText)
				.filter((text) -> text != null && !text.isBlank())
				.reduce((a, b) -> a + "\n\n" + b)
				.orElse(null);
	}
}
