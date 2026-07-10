package vn.edu.fpt.myfschoolse1913.document;

import jakarta.persistence.Basic;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "school_documents")
public class SchoolDocument {

	@Id
	@GeneratedValue
	private UUID id;

	@Column(nullable = false, length = 200)
	private String title;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 40)
	private SchoolDocumentCategory category;

	@Column(name = "subject_name", length = 120)
	private String subjectName;

	@Column(name = "file_name", nullable = false, length = 255)
	private String fileName;

	@Column(name = "mime_type", nullable = false, length = 120)
	private String mimeType;

	@Column(name = "size_bytes", nullable = false)
	private long sizeBytes;

	@Basic(fetch = FetchType.LAZY)
	@Column(nullable = false)
	private byte[] content;

	@Enumerated(EnumType.STRING)
	@Column(name = "ingest_status", nullable = false, length = 20)
	private SchoolDocumentIngestStatus ingestStatus;

	@Column(name = "ingest_error", length = 500)
	private String ingestError;

	@Column(name = "chunk_count")
	private Integer chunkCount;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt;

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt;

	protected SchoolDocument() {
	}

	public SchoolDocument(
			String title,
			SchoolDocumentCategory category,
			String subjectName,
			String fileName,
			String mimeType,
			byte[] content,
			Instant now
	) {
		this.title = title;
		this.category = category;
		this.subjectName = subjectName;
		this.fileName = fileName;
		this.mimeType = mimeType;
		this.sizeBytes = content.length;
		this.content = content;
		this.ingestStatus = SchoolDocumentIngestStatus.PENDING;
		this.createdAt = now;
		this.updatedAt = now;
	}

	public void markIndexed(int chunkCount, Instant now) {
		this.ingestStatus = SchoolDocumentIngestStatus.INDEXED;
		this.ingestError = null;
		this.chunkCount = chunkCount;
		this.updatedAt = now;
	}

	public void markFailed(String error, Instant now) {
		this.ingestStatus = SchoolDocumentIngestStatus.FAILED;
		this.ingestError = error;
		this.chunkCount = null;
		this.updatedAt = now;
	}

	public UUID getId() {
		return id;
	}

	public String getTitle() {
		return title;
	}

	public SchoolDocumentCategory getCategory() {
		return category;
	}

	public String getSubjectName() {
		return subjectName;
	}

	public String getFileName() {
		return fileName;
	}

	public String getMimeType() {
		return mimeType;
	}

	public long getSizeBytes() {
		return sizeBytes;
	}

	public byte[] getContent() {
		return content;
	}

	public SchoolDocumentIngestStatus getIngestStatus() {
		return ingestStatus;
	}

	public String getIngestError() {
		return ingestError;
	}

	public Integer getChunkCount() {
		return chunkCount;
	}

	public Instant getCreatedAt() {
		return createdAt;
	}

	public Instant getUpdatedAt() {
		return updatedAt;
	}
}
