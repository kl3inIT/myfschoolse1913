package vn.edu.fpt.myfschoolse1913.student;

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
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "class_timetable_slots")
public class ClassTimetableSlot {

	@Id
	@GeneratedValue
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "class_id", nullable = false)
	private SchoolClass schoolClass;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "semester_id", nullable = false)
	private Semester semester;

	@Column(name = "day_index", nullable = false)
	private short dayIndex;

	@Column(name = "lesson_number", nullable = false)
	private int lessonNumber;

	@Enumerated(EnumType.STRING)
	@Column(name = "slot_type", nullable = false, length = 30)
	private ClassTimetableSlotType slotType;

	@Column(nullable = false, length = 120)
	private String title;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "subject_id")
	private Subject subject;

	@Column(name = "room_name", length = 80)
	private String roomName;

	@Column(name = "teacher_name", length = 120)
	private String teacherName;

	@Column(name = "starts_at", nullable = false)
	private LocalTime startsAt;

	@Column(name = "ends_at", nullable = false)
	private LocalTime endsAt;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt = Instant.now();

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt = Instant.now();

	protected ClassTimetableSlot() {
	}

	public ClassTimetableSlot(
			SchoolClass schoolClass,
			Semester semester,
			int dayIndex,
			int lessonNumber,
			ClassTimetableSlotType slotType,
			String title,
			Subject subject,
			String roomName,
			String teacherName,
			LocalTime startsAt,
			LocalTime endsAt
	) {
		this.schoolClass = schoolClass;
		this.semester = semester;
		this.dayIndex = (short) dayIndex;
		this.lessonNumber = lessonNumber;
		this.slotType = slotType;
		this.title = title;
		this.subject = subject;
		this.roomName = roomName;
		this.teacherName = teacherName;
		this.startsAt = startsAt;
		this.endsAt = endsAt;
	}

	public UUID getId() {
		return id;
	}

	public SchoolClass getSchoolClass() {
		return schoolClass;
	}

	public Semester getSemester() {
		return semester;
	}

	public Subject getSubject() {
		return subject;
	}

	public Instant getUpdatedAt() {
		return updatedAt;
	}

	public int getDayIndex() {
		return dayIndex;
	}

	public int getLessonNumber() {
		return lessonNumber;
	}

	public ClassTimetableSlotType getSlotType() {
		return slotType;
	}

	public String getTitle() {
		return title;
	}

	public String getRoomName() {
		return roomName;
	}

	public String getTeacherName() {
		return teacherName;
	}

	public LocalTime getStartsAt() {
		return startsAt;
	}

	public LocalTime getEndsAt() {
		return endsAt;
	}

	public void updateDetails(
			ClassTimetableSlotType slotType,
			String title,
			Subject subject,
			String roomName,
			String teacherName,
			LocalTime startsAt,
			LocalTime endsAt
	) {
		this.slotType = slotType;
		this.title = title;
		this.subject = subject;
		this.roomName = roomName;
		this.teacherName = teacherName;
		this.startsAt = startsAt;
		this.endsAt = endsAt;
		this.updatedAt = Instant.now();
	}
}
