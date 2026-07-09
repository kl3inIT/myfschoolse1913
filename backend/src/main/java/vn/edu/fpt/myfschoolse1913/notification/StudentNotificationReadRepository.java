package vn.edu.fpt.myfschoolse1913.notification;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.fpt.myfschoolse1913.student.Student;

public interface StudentNotificationReadRepository extends JpaRepository<StudentNotificationRead, UUID> {

	List<StudentNotificationRead> findByStudentAndNotificationIn(
			Student student,
			List<SchoolNotification> notifications
	);

	Optional<StudentNotificationRead> findByStudentAndNotification(
			Student student,
			SchoolNotification notification
	);
}
