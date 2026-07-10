package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/timetable")
public class AdminTimetableController {

	private final AdminTimetableImportService adminTimetableImportService;
	private final AdminTimetableListService adminTimetableListService;

	public AdminTimetableController(
			AdminTimetableImportService adminTimetableImportService,
			AdminTimetableListService adminTimetableListService
	) {
		this.adminTimetableImportService = adminTimetableImportService;
		this.adminTimetableListService = adminTimetableListService;
	}

	@PostMapping("/import")
	public AdminTimetableImportResponse importTimetable(
			@Valid @RequestBody AdminTimetableImportRequest request
	) {
		return adminTimetableImportService.importTimetable(request);
	}

	@GetMapping
	public AdminTimetableListResponse listSlots(
			@RequestParam(defaultValue = "") String search,
			@RequestParam(defaultValue = "0") int page,
			@RequestParam(defaultValue = "20") int size
	) {
		return adminTimetableListService.listSlots(search, page, size);
	}
}
