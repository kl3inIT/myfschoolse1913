package vn.edu.fpt.myfschoolse1913.student;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/grades")
public class AdminGradeListController {

	private final AdminGradeListService adminGradeListService;

	public AdminGradeListController(AdminGradeListService adminGradeListService) {
		this.adminGradeListService = adminGradeListService;
	}

	@GetMapping
	public AdminGradeListResponse listGrades(
			@RequestParam(defaultValue = "") String search,
			@RequestParam(defaultValue = "0") int page,
			@RequestParam(defaultValue = "20") int size
	) {
		return adminGradeListService.listGrades(search, page, size);
	}
}
