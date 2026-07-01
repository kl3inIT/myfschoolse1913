package vn.edu.fpt.myfschoolse1913.student;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.user.AppUser;

@Entity
@Table(name = "students")
public class Student {

	@Id
	@GeneratedValue
	private UUID id;

	@OneToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false, unique = true)
	private AppUser user;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "class_id", nullable = false)
	private SchoolClass schoolClass;

	@Column(name = "student_code", nullable = false, unique = true, length = 40)
	private String studentCode;

	@Column(nullable = false, length = 40)
	private String status;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt = Instant.now();

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt = Instant.now();

	protected Student() {
	}

	public Student(AppUser user, SchoolClass schoolClass, String studentCode, String status) {
		this.user = user;
		this.schoolClass = schoolClass;
		this.studentCode = studentCode;
		this.status = status;
	}

	public UUID getId() {
		return id;
	}

	public AppUser getUser() {
		return user;
	}

	public SchoolClass getSchoolClass() {
		return schoolClass;
	}

	public String getStatus() {
		return status;
	}
}
