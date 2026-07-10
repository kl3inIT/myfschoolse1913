package vn.edu.fpt.myfschoolse1913.document;

import java.io.IOException;
import java.time.Clock;
import java.time.Instant;
import java.util.Locale;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AdminDocumentService {

	private static final Logger log = LoggerFactory.getLogger(AdminDocumentService.class);

	private final SchoolDocumentRepository documentRepository;
	private final SchoolDocumentIngestionService ingestionService;
	private final Clock clock;

	AdminDocumentService(
			SchoolDocumentRepository documentRepository,
			SchoolDocumentIngestionService ingestionService,
			Clock clock
	) {
		this.documentRepository = documentRepository;
		this.ingestionService = ingestionService;
		this.clock = clock;
	}

	@Transactional
	public AdminDocumentListResponse.Item upload(
			MultipartFile file,
			String title,
			String category,
			String subjectName
	) {
		if (file == null || file.isEmpty()) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Vui lòng chọn file tài liệu");
		}

		byte[] content;
		try {
			content = file.getBytes();
		} catch (IOException exception) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không đọc được file tải lên");
		}

		String fileName = file.getOriginalFilename() == null || file.getOriginalFilename().isBlank()
				? "tai-lieu"
				: file.getOriginalFilename();
		String resolvedTitle = title == null || title.isBlank() ? fileName : title.strip();
		if (resolvedTitle.length() > 200) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tiêu đề tối đa 200 ký tự");
		}

		Instant now = Instant.now(clock);
		var document = documentRepository.save(new SchoolDocument(
				resolvedTitle,
				parseCategory(category),
				subjectName == null || subjectName.isBlank() ? null : subjectName.strip(),
				fileName,
				file.getContentType() == null ? "application/octet-stream" : file.getContentType(),
				content,
				now
		));

		try {
			int chunkCount = ingestionService.ingest(document);
			document.markIndexed(chunkCount, Instant.now(clock));
		} catch (IllegalArgumentException exception) {
			// Unreadable file — reject the whole upload with the reason.
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, exception.getMessage());
		} catch (RuntimeException exception) {
			// Embedding backend hiccup — keep the row so the admin sees FAILED
			// and can delete/re-upload; the file itself is stored fine.
			log.warn("Ingestion failed for document {}", document.getId(), exception);
			document.markFailed("Chưa lập chỉ mục được, hãy xóa và tải lại", Instant.now(clock));
		}

		return AdminDocumentListResponse.Item.from(document);
	}

	@Transactional(readOnly = true)
	public AdminDocumentListResponse list(String search, String category, int page, int size) {
		int safePage = Math.max(page, 0);
		int safeSize = Math.clamp(size, 1, 200);
		var normalizedSearch = search == null ? "" : search.strip().toLowerCase(Locale.ROOT);
		var pageable = PageRequest.of(safePage, safeSize, Sort.by(Sort.Order.desc("updatedAt")));
		var result = category == null || category.isBlank()
				? documentRepository.searchForAdmin(normalizedSearch, pageable)
				: documentRepository.searchForAdminByCategory(
						normalizedSearch, parseCategory(category), pageable);

		return new AdminDocumentListResponse(
				safePage,
				safeSize,
				result.getTotalElements(),
				result.getTotalPages(),
				result.getContent().stream().map(AdminDocumentListResponse.Item::from).toList()
		);
	}

	@Transactional
	public void delete(UUID documentId) {
		var document = documentRepository.findById(documentId)
				.orElseThrow(() -> new ResponseStatusException(
						HttpStatus.NOT_FOUND, "Không tìm thấy tài liệu"));

		ingestionService.remove(document.getId());
		documentRepository.delete(document);
	}

	private SchoolDocumentCategory parseCategory(String category) {
		if (category == null || category.isBlank()) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Vui lòng chọn loại tài liệu");
		}
		try {
			return SchoolDocumentCategory.valueOf(category.strip().toUpperCase(Locale.ROOT));
		} catch (IllegalArgumentException exception) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Loại tài liệu không hợp lệ");
		}
	}
}
