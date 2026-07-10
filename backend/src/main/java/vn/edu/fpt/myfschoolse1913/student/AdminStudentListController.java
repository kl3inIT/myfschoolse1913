package vn.edu.fpt.myfschoolse1913.student;

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
@RequestMapping("/api/admin/students")
public class AdminStudentListController {

	private final AdminStudentListService adminStudentListService;

	public AdminStudentListController(AdminStudentListService adminStudentListService) {
		this.adminStudentListService = adminStudentListService;
	}

	@GetMapping("/stats")
	public AdminStudentStatsResponse studentStats() {
		return adminStudentListService.studentStats();
	}

	@GetMapping("/{id}")
	public AdminStudentListResponse.Item getStudent(@PathVariable UUID id) {
		return adminStudentListService.getStudent(id);
	}

	@PutMapping("/{id}")
	public AdminStudentListResponse.Item updateStudent(
			@PathVariable UUID id,
			@Valid @RequestBody AdminStudentUpdateRequest request
	) {
		return adminStudentListService.updateStudent(id, request);
	}

	@GetMapping
	public AdminStudentListResponse listStudents(
			@RequestParam(defaultValue = "") String search,
			@RequestParam(defaultValue = "0") int page,
			@RequestParam(defaultValue = "20") int size
	) {
		return adminStudentListService.listStudents(search, page, size);
	}
}
