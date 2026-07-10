package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/grades")
public class AdminGradeImportController {

	private final AdminGradeImportService adminGradeImportService;

	public AdminGradeImportController(AdminGradeImportService adminGradeImportService) {
		this.adminGradeImportService = adminGradeImportService;
	}

	@PostMapping("/import")
	public AdminGradeImportResponse importGrades(@Valid @RequestBody AdminGradeImportRequest request) {
		return adminGradeImportService.importGrades(request);
	}
}
