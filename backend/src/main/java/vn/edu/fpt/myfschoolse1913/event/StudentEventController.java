package vn.edu.fpt.myfschoolse1913.event;

import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/students/me/events")
public class StudentEventController {

	private final StudentEventService eventService;

	public StudentEventController(StudentEventService eventService) {
		this.eventService = eventService;
	}

	@GetMapping
	public StudentEventsResponse events(@AuthenticationPrincipal Jwt jwt) {
		return eventService.getEvents(UUID.fromString(jwt.getSubject()));
	}
}
