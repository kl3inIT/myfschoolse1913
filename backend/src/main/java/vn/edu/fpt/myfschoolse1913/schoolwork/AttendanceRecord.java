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
import vn.edu.fpt.myfschoolse1913.student.Student;
import vn.edu.fpt.myfschoolse1913.user.AppUser;

@Entity
@Table(name = "attendance_records")
public class AttendanceRecord {

  @Id @GeneratedValue private UUID id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "teaching_assignment_id", nullable = false)
  private TeachingAssignment teachingAssignment;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "student_id", nullable = false)
  private Student student;

  @Column(name = "attendance_date", nullable = false)
  private LocalDate attendanceDate;

  @Column(name = "lesson_number", nullable = false)
  private int lessonNumber;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 30)
  private AttendanceStatus status;

  @Column(length = 255)
  private String note;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "recorded_by", nullable = false)
  private AppUser recordedBy;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt = Instant.now();

  protected AttendanceRecord() {}

  public AttendanceRecord(
      TeachingAssignment assignment,
      Student student,
      LocalDate date,
      int lessonNumber,
      AttendanceStatus status,
      String note,
      AppUser recordedBy) {
    this.teachingAssignment = assignment;
    this.student = student;
    this.attendanceDate = date;
    this.lessonNumber = lessonNumber;
    this.status = status;
    this.note = note;
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

  public LocalDate getAttendanceDate() {
    return attendanceDate;
  }

  public int getLessonNumber() {
    return lessonNumber;
  }

  public AttendanceStatus getStatus() {
    return status;
  }

  public String getNote() {
    return note;
  }

  public void update(AttendanceStatus status, String note, AppUser recordedBy) {
    this.status = status;
    this.note = note;
    this.recordedBy = recordedBy;
    this.updatedAt = Instant.now();
  }
}
