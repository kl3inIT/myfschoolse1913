package vn.edu.fpt.myfschoolse1913.notification;

import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/students/me/notifications")
public class StudentNotificationController {

	private final StudentNotificationService notificationService;

	public StudentNotificationController(StudentNotificationService notificationService) {
		this.notificationService = notificationService;
	}

	@GetMapping
	public StudentNotificationsResponse notifications(@AuthenticationPrincipal Jwt jwt) {
		return notificationService.getNotifications(UUID.fromString(jwt.getSubject()));
	}

	@GetMapping("/{notificationId}")
	public StudentNotificationDetailResponse notification(
			@AuthenticationPrincipal Jwt jwt,
			@PathVariable UUID notificationId
	) {
		return notificationService.getNotification(UUID.fromString(jwt.getSubject()), notificationId);
	}
}
