package vn.edu.fpt.myfschoolse1913.student;

import java.time.LocalDate;
import java.util.UUID;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/students/me/schedule")
public class StudentScheduleController {

	private final StudentScheduleService scheduleService;

	public StudentScheduleController(StudentScheduleService scheduleService) {
		this.scheduleService = scheduleService;
	}

	@GetMapping
	public StudentScheduleResponse schedule(
			@AuthenticationPrincipal Jwt jwt,
			@RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate weekStart
	) {
		return scheduleService.getSchedule(UUID.fromString(jwt.getSubject()), weekStart);
	}
}
