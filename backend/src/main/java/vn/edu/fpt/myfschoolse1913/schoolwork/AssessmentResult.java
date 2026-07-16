package vn.edu.fpt.myfschoolse1913.schoolwork;

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
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.student.Student;
import vn.edu.fpt.myfschoolse1913.user.AppUser;

@Entity
@Table(name = "assessment_results")
public class AssessmentResult {

  @Id @GeneratedValue private UUID id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "teaching_assignment_id", nullable = false)
  private TeachingAssignment teachingAssignment;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "student_id", nullable = false)
  private Student student;

  @Enumerated(EnumType.STRING)
  @Column(name = "assessment_type", nullable = false, length = 30)
  private AssessmentType type;

  @Column(name = "sequence_number", nullable = false)
  private int sequenceNumber;

  @Column(nullable = false, length = 120)
  private String title;

  @Column(precision = 4, scale = 1)
  private BigDecimal score;

  @Column(length = 255)
  private String comment;

  @Column(nullable = false)
  private boolean published;

  @Column(name = "published_at")
  private Instant publishedAt;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "recorded_by", nullable = false)
  private AppUser recordedBy;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt = Instant.now();

  protected AssessmentResult() {}

  public AssessmentResult(
      TeachingAssignment assignment,
      Student student,
      AssessmentType type,
      int sequenceNumber,
      String title,
      BigDecimal score,
      String comment,
      boolean published,
      AppUser recordedBy) {
    this.teachingAssignment = assignment;
    this.student = student;
    this.type = type;
    this.sequenceNumber = sequenceNumber;
    this.title = title;
    this.score = score;
    this.comment = comment;
    this.published = published;
    this.publishedAt = published ? Instant.now() : null;
    this.recordedBy = recordedBy;
  }

  public UUID getId() {
    return id;
  }

  public TeachingAssignment getTeachingAssignment() {
    return teachingAssignment;
  }

  public Student getStudent() {
    return student;
  }

  public AssessmentType getType() {
    return type;
  }

  public int getSequenceNumber() {
    return sequenceNumber;
  }

  public String getTitle() {
    return title;
  }

  public BigDecimal getScore() {
    return score;
  }

  public String getComment() {
    return comment;
  }

  public boolean isPublished() {
    return published;
  }

  public void update(
      String title, BigDecimal score, String comment, boolean published, AppUser recordedBy) {
    this.title = title;
    this.score = score;
    this.comment = comment;
    if (!this.published && published) this.publishedAt = Instant.now();
    this.published = published;
    this.recordedBy = recordedBy;
    this.updatedAt = Instant.now();
  }
}
