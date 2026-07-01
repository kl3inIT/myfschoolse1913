package vn.edu.fpt.myfschoolse1913.student;

import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/students/me/dashboard")
public class StudentDashboardController {

	private final StudentDashboardService dashboardService;

	public StudentDashboardController(StudentDashboardService dashboardService) {
		this.dashboardService = dashboardService;
	}

	@GetMapping
	public StudentDashboardResponse dashboard(@AuthenticationPrincipal Jwt jwt) {
		return dashboardService.getDashboard(UUID.fromString(jwt.getSubject()));
	}
}
