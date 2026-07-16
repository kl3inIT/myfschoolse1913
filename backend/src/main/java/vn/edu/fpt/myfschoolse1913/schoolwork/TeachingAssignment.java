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
import java.time.LocalDate;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.student.SchoolClass;
import vn.edu.fpt.myfschoolse1913.student.Semester;
import vn.edu.fpt.myfschoolse1913.student.Subject;

@Entity
@Table(name = "teaching_assignments")
public class TeachingAssignment {

  @Id @GeneratedValue private UUID id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "teacher_id", nullable = false)
  private TeacherProfile teacher;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "class_id", nullable = false)
  private SchoolClass schoolClass;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "subject_id", nullable = false)
  private Subject subject;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "semester_id", nullable = false)
  private Semester semester;

  @Enumerated(EnumType.STRING)
  @Column(name = "assignment_type", nullable = false, length = 30)
  private TeachingAssignmentType type;

  @Column(name = "starts_on")
  private LocalDate startsOn;

  @Column(name = "ends_on")
  private LocalDate endsOn;

  @Column(nullable = false)
  private boolean active = true;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt = Instant.now();

  protected TeachingAssignment() {}

  public TeachingAssignment(
      TeacherProfile teacher,
      SchoolClass schoolClass,
      Subject subject,
      Semester semester,
      TeachingAssignmentType type,
      LocalDate startsOn,
      LocalDate endsOn) {
    this.teacher = teacher;
    this.schoolClass = schoolClass;
    this.subject = subject;
    this.semester = semester;
    this.type = type;
    this.startsOn = startsOn;
    this.endsOn = endsOn;
  }

  public UUID getId() {
    return id;
  }

  public TeacherProfile getTeacher() {
    return teacher;
  }

  public SchoolClass getSchoolClass() {
    return schoolClass;
  }

  public Subject getSubject() {
    return subject;
  }

  public Semester getSemester() {
    return semester;
  }

  public TeachingAssignmentType getType() {
    return type;
  }

  public LocalDate getStartsOn() {
    return startsOn;
  }

  public LocalDate getEndsOn() {
    return endsOn;
  }

  public boolean isActive() {
    return active;
  }

  public boolean isEffectiveOn(LocalDate date) {
    return active
        && (startsOn == null || !date.isBefore(startsOn))
        && (endsOn == null || !date.isAfter(endsOn));
  }

  public void update(
      TeachingAssignmentType type, LocalDate startsOn, LocalDate endsOn, boolean active) {
    this.type = type;
    this.startsOn = startsOn;
    this.endsOn = endsOn;
    this.active = active;
    this.updatedAt = Instant.now();
  }
}
