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
import java.time.Instant;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.student.Semester;
import vn.edu.fpt.myfschoolse1913.student.Student;
import vn.edu.fpt.myfschoolse1913.user.AppUser;

@Entity
@Table(name = "student_conduct_summaries")
public class StudentConductSummary {
  @Id @GeneratedValue private UUID id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "homeroom_assignment_id", nullable = false)
  private HomeroomAssignment homeroomAssignment;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "student_id", nullable = false)
  private Student student;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "semester_id", nullable = false)
  private Semester semester;

  @Enumerated(EnumType.STRING)
  @Column(name = "conduct_level", nullable = false, length = 30)
  private ConductLevel level;

  @Column(length = 500)
  private String comment;

  @Column(nullable = false)
  private boolean published;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "recorded_by", nullable = false)
  private AppUser recordedBy;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt = Instant.now();

  protected StudentConductSummary() {}

  public StudentConductSummary(
      HomeroomAssignment assignment,
      Student student,
      Semester semester,
      ConductLevel level,
      String comment,
      boolean published,
      AppUser recordedBy) {
    this.homeroomAssignment = assignment;
    this.student = student;
    this.semester = semester;
    this.level = level;
    this.comment = comment;
    this.published = published;
    this.recordedBy = recordedBy;
  }

  public UUID getId() {
    return id;
  }

  public Student getStudent() {
    return student;
  }

  public Semester getSemester() {
    return semester;
  }

  public ConductLevel getLevel() {
    return level;
  }

  public String getComment() {
    return comment;
  }

  public boolean isPublished() {
    return published;
  }

  public void update(ConductLevel level, String comment, boolean published, AppUser recordedBy) {
    this.level = level;
    this.comment = comment;
    this.published = published;
    this.recordedBy = recordedBy;
    this.updatedAt = Instant.now();
  }
}
