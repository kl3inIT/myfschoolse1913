package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.student.AcademicYear;
import vn.edu.fpt.myfschoolse1913.student.SchoolClass;

@Entity
@Table(name = "homeroom_assignments")
public class HomeroomAssignment {

  @Id @GeneratedValue private UUID id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "teacher_id", nullable = false)
  private TeacherProfile teacher;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "class_id", nullable = false)
  private SchoolClass schoolClass;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "academic_year_id", nullable = false)
  private AcademicYear academicYear;

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

  protected HomeroomAssignment() {}

  public HomeroomAssignment(
      TeacherProfile teacher,
      SchoolClass schoolClass,
      AcademicYear academicYear,
      LocalDate startsOn,
      LocalDate endsOn) {
    this.teacher = teacher;
    this.schoolClass = schoolClass;
    this.academicYear = academicYear;
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

  public AcademicYear getAcademicYear() {
    return academicYear;
  }

  public boolean isActive() {
    return active;
  }

  public LocalDate getStartsOn() {
    return startsOn;
  }

  public LocalDate getEndsOn() {
    return endsOn;
  }

  public void update(LocalDate startsOn, LocalDate endsOn, boolean active) {
    this.startsOn = startsOn;
    this.endsOn = endsOn;
    this.active = active;
    this.updatedAt = Instant.now();
  }
}
