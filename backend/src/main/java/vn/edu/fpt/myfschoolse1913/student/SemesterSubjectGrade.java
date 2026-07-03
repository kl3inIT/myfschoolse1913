package vn.edu.fpt.myfschoolse1913.student;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "semester_subject_grades")
public class SemesterSubjectGrade {

	@Id
	@GeneratedValue
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "student_id", nullable = false)
	private Student student;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "semester_id", nullable = false)
	private Semester semester;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "subject_id", nullable = false)
	private Subject subject;

	@Column(name = "average_score", nullable = false, precision = 4, scale = 1)
	private BigDecimal averageScore;

	@Column(name = "formative_score", precision = 4, scale = 1)
	private BigDecimal formativeScore;

	@Column(name = "midterm_score", precision = 4, scale = 1)
	private BigDecimal midtermScore;

	@Column(name = "final_score", precision = 4, scale = 1)
	private BigDecimal finalScore;

	@Column(nullable = false, length = 255)
	private String detail;

	@Column(name = "teacher_comment", length = 255)
	private String teacherComment;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt = Instant.now();

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt = Instant.now();

	protected SemesterSubjectGrade() {
	}

	public SemesterSubjectGrade(
			Student student,
			Semester semester,
			Subject subject,
			BigDecimal formativeScore,
			BigDecimal midtermScore,
			BigDecimal finalScore,
			BigDecimal averageScore,
			String detail,
			String teacherComment
	) {
		this.student = student;
		this.semester = semester;
		this.subject = subject;
		this.formativeScore = formativeScore;
		this.midtermScore = midtermScore;
		this.finalScore = finalScore;
		this.averageScore = averageScore;
		this.detail = detail;
		this.teacherComment = teacherComment;
	}

	public Subject getSubject() {
		return subject;
	}

	public BigDecimal getAverageScore() {
		return averageScore;
	}

	public BigDecimal getFormativeScore() {
		return formativeScore;
	}

	public BigDecimal getMidtermScore() {
		return midtermScore;
	}

	public BigDecimal getFinalScore() {
		return finalScore;
	}

	public String getDetail() {
		return detail;
	}

	public String getTeacherComment() {
		return teacherComment;
	}
}
