package vn.edu.fpt.myfschoolse1913.application;

import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/applications")
public class AdminApplicationController {

	private final AdminApplicationService adminApplicationService;

	public AdminApplicationController(AdminApplicationService adminApplicationService) {
		this.adminApplicationService = adminApplicationService;
	}

	@GetMapping("/stats")
	public AdminApplicationStatsResponse applicationStats() {
		return adminApplicationService.applicationStats();
	}

	@GetMapping
	public AdminApplicationListResponse listApplications(
			@RequestParam(defaultValue = "") String search,
			@RequestParam(defaultValue = "") String status,
			@RequestParam(defaultValue = "0") int page,
			@RequestParam(defaultValue = "20") int size
	) {
		return adminApplicationService.listApplications(search, status, page, size);
	}

	@PutMapping("/{id}")
	public AdminApplicationListResponse.Item reviewApplication(
			@PathVariable UUID id,
			@Valid @RequestBody AdminApplicationReviewRequest request
	) {
		return adminApplicationService.reviewApplication(id, request);
	}
}
