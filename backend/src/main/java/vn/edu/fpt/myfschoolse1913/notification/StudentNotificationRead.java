package vn.edu.fpt.myfschoolse1913.notification;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.Instant;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.student.Student;

@Entity
@Table(
		name = "student_notification_reads",
		uniqueConstraints = @UniqueConstraint(
				name = "uk_student_notification_read",
				columnNames = {"student_id", "notification_id"}
		)
)
public class StudentNotificationRead {

	@Id
	@GeneratedValue
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "student_id", nullable = false)
	private Student student;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "notification_id", nullable = false)
	private SchoolNotification notification;

	@Column(name = "read_at", nullable = false)
	private Instant readAt = Instant.now();

	protected StudentNotificationRead() {
	}

	public StudentNotificationRead(Student student, SchoolNotification notification) {
		this.student = student;
		this.notification = notification;
	}

	public SchoolNotification getNotification() {
		return notification;
	}
}
