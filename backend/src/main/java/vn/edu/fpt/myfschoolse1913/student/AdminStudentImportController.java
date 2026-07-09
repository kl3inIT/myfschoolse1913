package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/students")
public class AdminStudentImportController {

	private final StudentImportService studentImportService;

	public AdminStudentImportController(StudentImportService studentImportService) {
		this.studentImportService = studentImportService;
	}

	@PostMapping("/import")
	public AdminStudentImportResponse importStudents(@Valid @RequestBody AdminStudentImportRequest request) {
		return studentImportService.importStudents(request);
	}
}
