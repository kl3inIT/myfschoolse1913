package vn.edu.fpt.myfschoolse1913.notification;

import java.time.Instant;
import java.util.UUID;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.notification.AdminNotificationListResponse.Item;

@Service
public class AdminNotificationService {

	private static final int MAX_PAGE_SIZE = 100;

	private final SchoolNotificationRepository notificationRepository;

	public AdminNotificationService(SchoolNotificationRepository notificationRepository) {
		this.notificationRepository = notificationRepository;
	}

	@Transactional
	public Item publishNotification(AdminNotificationRequest request) {
		var notification = notificationRepository.save(new SchoolNotification(
				request.title().trim(),
				request.body().trim(),
				request.category(),
				request.audience(),
				Instant.now(),
				request.pinned(),
				true
		));
		return toItem(notification);
	}

	@Transactional
	public void deactivateNotification(UUID id) {
		var notification = notificationRepository.findByIdAndActiveTrue(id)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy thông báo"));
		notification.deactivate();
	}

	@Transactional(readOnly = true)
	public AdminNotificationListResponse listNotifications(int page, int size) {
		var safePage = Math.max(page, 0);
		var safeSize = Math.min(Math.max(size, 1), MAX_PAGE_SIZE);
		var pageable = PageRequest.of(safePage, safeSize, Sort.by("publishedAt").descending());

		var result = notificationRepository.findAll(pageable);
		var items = result.getContent().stream().map(this::toItem).toList();

		return new AdminNotificationListResponse(
				safePage,
				safeSize,
				result.getTotalElements(),
				result.getTotalPages(),
				items
		);
	}

	private Item toItem(SchoolNotification notification) {
		return new Item(
				notification.getId(),
				notification.getTitle(),
				notification.getBody(),
				notification.getCategory(),
				notification.getAudience(),
				notification.getPublishedAt(),
				notification.isPinned(),
				notification.isActive()
		);
	}
}
