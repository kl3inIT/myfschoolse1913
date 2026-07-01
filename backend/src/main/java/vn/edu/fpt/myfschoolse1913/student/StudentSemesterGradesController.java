package vn.edu.fpt.myfschoolse1913.student;

import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/students/me/semester-grades")
public class StudentSemesterGradesController {

	private final StudentSemesterGradesService gradesService;

	public StudentSemesterGradesController(StudentSemesterGradesService gradesService) {
		this.gradesService = gradesService;
	}

	@GetMapping
	public StudentSemesterGradesResponse semesterGrades(@AuthenticationPrincipal Jwt jwt) {
		return gradesService.getSemesterGrades(UUID.fromString(jwt.getSubject()));
	}
}
