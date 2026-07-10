package vn.edu.fpt.myfschoolse1913.notification;

import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/notifications")
public class AdminNotificationController {

	private final AdminNotificationService adminNotificationService;

	public AdminNotificationController(AdminNotificationService adminNotificationService) {
		this.adminNotificationService = adminNotificationService;
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public AdminNotificationListResponse.Item publishNotification(
			@Valid @RequestBody AdminNotificationRequest request
	) {
		return adminNotificationService.publishNotification(request);
	}

	@GetMapping
	public AdminNotificationListResponse listNotifications(
			@RequestParam(defaultValue = "0") int page,
			@RequestParam(defaultValue = "20") int size
	) {
		return adminNotificationService.listNotifications(page, size);
	}

	@DeleteMapping("/{id}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void deactivateNotification(@PathVariable UUID id) {
		adminNotificationService.deactivateNotification(id);
	}
}
