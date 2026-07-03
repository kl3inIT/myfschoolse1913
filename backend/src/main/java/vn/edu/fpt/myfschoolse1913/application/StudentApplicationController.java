package vn.edu.fpt.myfschoolse1913.application;

import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/students/me/applications")
public class StudentApplicationController {

	private final StudentApplicationService applicationService;

	public StudentApplicationController(StudentApplicationService applicationService) {
		this.applicationService = applicationService;
	}

	@GetMapping
	public StudentApplicationsResponse applications(
			@AuthenticationPrincipal Jwt jwt,
			@RequestParam(required = false) StudentApplicationStatus status
	) {
		return applicationService.getApplications(UUID.fromString(jwt.getSubject()), status);
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public StudentApplicationsResponse.ApplicationItem create(
			@AuthenticationPrincipal Jwt jwt,
			@Valid @RequestBody CreateStudentApplicationRequest request
	) {
		return applicationService.createApplication(UUID.fromString(jwt.getSubject()), request);
	}
}
