package vn.edu.fpt.myfschoolse1913.notification;

import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.student.CurrentStudentService;

@Service
public class StudentNotificationService {

	private final CurrentStudentService currentStudentService;
	private final SchoolNotificationRepository notificationRepository;

	public StudentNotificationService(
			CurrentStudentService currentStudentService,
			SchoolNotificationRepository notificationRepository
	) {
		this.currentStudentService = currentStudentService;
		this.notificationRepository = notificationRepository;
	}

	@Transactional(readOnly = true)
	public StudentNotificationsResponse getNotifications(UUID userId) {
		currentStudentService.requireCurrentStudent(userId);
		var notifications = notificationRepository.findByActiveTrueOrderByPinnedDescPublishedAtDesc();

		return new StudentNotificationsResponse(
				notifications.stream()
						.map(this::toItem)
						.toList()
		);
	}

	private StudentNotificationsResponse.NotificationItem toItem(SchoolNotification notification) {
		return new StudentNotificationsResponse.NotificationItem(
				notification.getId(),
				notification.getTitle(),
				notification.getBody(),
				notification.getCategory().name(),
				notification.getPublishedAt(),
				notification.isPinned()
		);
	}
}
