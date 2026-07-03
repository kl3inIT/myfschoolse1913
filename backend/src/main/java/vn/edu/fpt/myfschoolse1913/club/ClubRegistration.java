package vn.edu.fpt.myfschoolse1913.club;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.student.Student;

@Entity
@Table(name = "club_registrations")
public class ClubRegistration {

	@Id
	@GeneratedValue
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "student_id", nullable = false)
	private Student student;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "club_id", nullable = false)
	private SchoolClub club;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 30)
	private ClubRegistrationStatus status = ClubRegistrationStatus.PENDING;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt = Instant.now();

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt = Instant.now();

	@Column(name = "reviewed_at")
	private Instant reviewedAt;

	protected ClubRegistration() {
	}

	public ClubRegistration(Student student, SchoolClub club) {
		this.student = student;
		this.club = club;
	}

	public SchoolClub getClub() {
		return club;
	}

	public ClubRegistrationStatus getStatus() {
		return status;
	}

	public void approve(Instant reviewedAt) {
		this.status = ClubRegistrationStatus.APPROVED;
		this.reviewedAt = reviewedAt;
		this.updatedAt = reviewedAt;
	}
}
