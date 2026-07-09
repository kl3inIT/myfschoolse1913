package vn.edu.fpt.myfschoolse1913.notification;

import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.student.CurrentStudentService;

@Service
public class StudentNotificationService {

	private final CurrentStudentService currentStudentService;
	private final SchoolNotificationRepository notificationRepository;
	private final StudentNotificationReadRepository readRepository;

	public StudentNotificationService(
			CurrentStudentService currentStudentService,
			SchoolNotificationRepository notificationRepository,
			StudentNotificationReadRepository readRepository
	) {
		this.currentStudentService = currentStudentService;
		this.notificationRepository = notificationRepository;
		this.readRepository = readRepository;
	}

	@Transactional(readOnly = true)
	public StudentNotificationsResponse getNotifications(UUID userId) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var notifications = notificationRepository.findByActiveTrueOrderByPinnedDescPublishedAtDesc();
		Set<UUID> readNotificationIds = readRepository.findByStudentAndNotificationIn(student, notifications).stream()
				.map((read) -> read.getNotification().getId())
				.collect(Collectors.toSet());

		return new StudentNotificationsResponse(
				notifications.stream()
						.map((notification) -> toItem(notification, readNotificationIds.contains(notification.getId())))
						.toList()
		);
	}

	@Transactional
	public StudentNotificationDetailResponse getNotification(UUID userId, UUID notificationId) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var notification = notificationRepository.findByIdAndActiveTrue(notificationId)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy thông báo"));

		readRepository.findByStudentAndNotification(student, notification)
				.orElseGet(() -> readRepository.save(new StudentNotificationRead(student, notification)));

		return new StudentNotificationDetailResponse(
				notification.getId(),
				notification.getTitle(),
				notification.getBody(),
				notification.getCategory().name(),
				notification.getPublishedAt(),
				notification.isPinned(),
				true
		);
	}

	private StudentNotificationsResponse.NotificationItem toItem(
			SchoolNotification notification,
			boolean read
	) {
		return new StudentNotificationsResponse.NotificationItem(
				notification.getId(),
				notification.getTitle(),
				notification.getBody(),
				notification.getCategory().name(),
				notification.getPublishedAt(),
				notification.isPinned(),
				read
		);
	}
}
