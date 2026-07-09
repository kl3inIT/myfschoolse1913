package vn.edu.fpt.myfschoolse1913.notification;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SchoolNotificationRepository extends JpaRepository<SchoolNotification, UUID> {

	List<SchoolNotification> findByActiveTrueOrderByPinnedDescPublishedAtDesc();

	Optional<SchoolNotification> findByIdAndActiveTrue(UUID id);

	Optional<SchoolNotification> findByTitleAndPublishedAt(String title, Instant publishedAt);
}
