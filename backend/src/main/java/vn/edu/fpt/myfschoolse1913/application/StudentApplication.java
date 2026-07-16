package vn.edu.fpt.myfschoolse1913.application;

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
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.student.Student;
import vn.edu.fpt.myfschoolse1913.user.AppUser;

@Entity
@Table(name = "student_applications")
public class StudentApplication {

	@Id
	@GeneratedValue
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "student_id", nullable = false)
	private Student student;

	@Enumerated(EnumType.STRING)
	@Column(name = "application_type", nullable = false, length = 40)
	private StudentApplicationType type;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 30)
	private StudentApplicationStatus status = StudentApplicationStatus.PENDING;

	@Column(name = "target_date", nullable = false)
	private LocalDate targetDate;

	@Column(name = "end_date")
	private LocalDate endDate;

	@Column(name = "requested_time")
	private LocalTime requestedTime;

	@Column(nullable = false, length = 200)
	private String reason;

	@Column(length = 1000)
	private String details;

	@Column(name = "reviewer_note", length = 500)
	private String reviewerNote;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt = Instant.now();

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt = Instant.now();

	@Column(name = "reviewed_at")
	private Instant reviewedAt;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "created_by_user_id")
	private AppUser createdBy;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "reviewed_by_user_id")
	private AppUser reviewedBy;

	protected StudentApplication() {
	}

	public StudentApplication(
			Student student,
			StudentApplicationType type,
			LocalDate targetDate,
			LocalTime requestedTime,
			String reason,
			String details
	) {
		this.student = student;
		this.type = type;
		this.targetDate = targetDate;
		this.endDate = targetDate;
		this.requestedTime = requestedTime;
		this.reason = reason;
		this.details = details;
	}

	public StudentApplication(
			Student student,
			StudentApplicationType type,
			LocalDate targetDate,
			LocalDate endDate,
			LocalTime requestedTime,
			String reason,
			String details,
			AppUser createdBy
	) {
		this(student, type, targetDate, requestedTime, reason, details);
		this.endDate = endDate == null ? targetDate : endDate;
		this.createdBy = createdBy;
	}

	public UUID getId() {
		return id;
	}

	public Student getStudent() {
		return student;
	}

	public String getReviewerNote() {
		return reviewerNote;
	}

	public Instant getReviewedAt() {
		return reviewedAt;
	}

	public StudentApplicationType getType() {
		return type;
	}

	public StudentApplicationStatus getStatus() {
		return status;
	}

	public LocalDate getTargetDate() {
		return targetDate;
	}

	public LocalDate getEndDate() {
		return endDate == null ? targetDate : endDate;
	}

	public LocalTime getRequestedTime() {
		return requestedTime;
	}

	public String getReason() {
		return reason;
	}

	public String getDetails() {
		return details;
	}

	public Instant getCreatedAt() {
		return createdAt;
	}

	public AppUser getCreatedBy() { return createdBy; }
	public AppUser getReviewedBy() { return reviewedBy; }

	public void approve(String reviewerNote, Instant reviewedAt) {
		this.status = StudentApplicationStatus.APPROVED;
		this.reviewerNote = reviewerNote;
		this.reviewedAt = reviewedAt;
		this.updatedAt = reviewedAt;
	}

	public void reject(String reviewerNote, Instant reviewedAt) {
		this.status = StudentApplicationStatus.REJECTED;
		this.reviewerNote = reviewerNote;
		this.reviewedAt = reviewedAt;
		this.updatedAt = reviewedAt;
	}

	public void approve(String reviewerNote, Instant reviewedAt, AppUser reviewedBy) {
		approve(reviewerNote, reviewedAt);
		this.reviewedBy = reviewedBy;
	}

	public void reject(String reviewerNote, Instant reviewedAt, AppUser reviewedBy) {
		reject(reviewerNote, reviewedAt);
		this.reviewedBy = reviewedBy;
	}
}
