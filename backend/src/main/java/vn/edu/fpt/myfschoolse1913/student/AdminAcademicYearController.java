package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/academic-years")
public class AdminAcademicYearController {

	private final AdminAcademicYearService adminAcademicYearService;

	public AdminAcademicYearController(AdminAcademicYearService adminAcademicYearService) {
		this.adminAcademicYearService = adminAcademicYearService;
	}

	@GetMapping
	public AdminAcademicYearsResponse listAcademicYears() {
		return adminAcademicYearService.listAcademicYears();
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public AdminAcademicYearsResponse.Year createAcademicYear(
			@Valid @RequestBody AdminAcademicYearRequest request
	) {
		return adminAcademicYearService.createAcademicYear(request);
	}

	@PostMapping("/{yearId}/classes")
	@ResponseStatus(HttpStatus.CREATED)
	public AdminAcademicYearsResponse.SchoolClassItem createSchoolClass(
			@PathVariable UUID yearId,
			@Valid @RequestBody AdminSchoolClassRequest request
	) {
		return adminAcademicYearService.createSchoolClass(yearId, request);
	}
}
