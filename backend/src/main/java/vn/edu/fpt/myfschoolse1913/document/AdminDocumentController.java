package vn.edu.fpt.myfschoolse1913.document;

import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/admin/documents")
public class AdminDocumentController {

	private final AdminDocumentService documentService;

	public AdminDocumentController(AdminDocumentService documentService) {
		this.documentService = documentService;
	}

	@PostMapping
	public AdminDocumentListResponse.Item upload(
			@RequestParam("file") MultipartFile file,
			@RequestParam(required = false) String title,
			@RequestParam String category,
			@RequestParam(required = false) String subjectName
	) {
		return documentService.upload(file, title, category, subjectName);
	}

	@GetMapping
	public AdminDocumentListResponse list(
			@RequestParam(required = false) String search,
			@RequestParam(required = false) String category,
			@RequestParam(defaultValue = "0") int page,
			@RequestParam(defaultValue = "20") int size
	) {
		return documentService.list(search, category, page, size);
	}

	@DeleteMapping("/{documentId}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@PathVariable UUID documentId) {
		documentService.delete(documentId);
	}
}
