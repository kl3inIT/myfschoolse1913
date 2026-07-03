package vn.edu.fpt.myfschoolse1913.student;

import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StudentScheduleService {

	private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

	private final CurrentStudentService currentStudentService;
	private final SemesterRepository semesterRepository;
	private final ClassTimetableSlotRepository timetableSlotRepository;
	private final Clock clock;

	public StudentScheduleService(
			CurrentStudentService currentStudentService,
			SemesterRepository semesterRepository,
			ClassTimetableSlotRepository timetableSlotRepository,
			Clock clock
	) {
		this.currentStudentService = currentStudentService;
		this.semesterRepository = semesterRepository;
		this.timetableSlotRepository = timetableSlotRepository;
		this.clock = clock;
	}

	@Transactional(readOnly = true)
	public StudentScheduleResponse getSchedule(java.util.UUID userId, LocalDate requestedWeekStart) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var today = LocalDate.now(clock);
		var weekStart = normalizeWeekStart(requestedWeekStart == null ? today : requestedWeekStart);
		var semester = currentSemester(student);
		var slots = timetableSlotRepository.findBySchoolClassAndSemesterOrderByDayIndexAscLessonNumberAsc(
				student.getSchoolClass(),
				semester
		);

		return new StudentScheduleResponse(
				weekStart,
				today,
				student.getSchoolClass().getAcademicYear().getName(),
				semester.getName(),
				buildDays(weekStart, today, slots)
		);
	}

	@Transactional(readOnly = true)
	public List<StudentDashboardResponse.TodayScheduleItem> getTodayScheduleItems(Student student) {
		var semester = currentSemester(student);
		var today = LocalDate.now(clock);
		var slots = timetableSlotRepository.findBySchoolClassAndSemesterAndDayIndexOrderByLessonNumberAsc(
				student.getSchoolClass(),
				semester,
				(short) today.getDayOfWeek().getValue()
		);

		return slots.stream()
				.map((slot) -> new StudentDashboardResponse.TodayScheduleItem(
						slot.getTitle(),
						dashboardSubtitle(slot),
						formatTime(slot.getStartsAt())
				))
				.toList();
	}

	private List<StudentScheduleResponse.ScheduleDay> buildDays(
			LocalDate weekStart,
			LocalDate today,
			List<ClassTimetableSlot> slots
	) {
		return weekStart.datesUntil(weekStart.plusDays(7))
				.map((date) -> new StudentScheduleResponse.ScheduleDay(
						date,
						dayLabel(date.getDayOfWeek()),
						date.equals(today),
						itemsForDay(date, slots)
				))
				.toList();
	}

	private List<StudentScheduleResponse.ScheduleItem> itemsForDay(
			LocalDate date,
			List<ClassTimetableSlot> slots
	) {
		var dayIndex = date.getDayOfWeek().getValue();
		return slots.stream()
				.filter((slot) -> slot.getDayIndex() == dayIndex)
				.map((slot) -> new StudentScheduleResponse.ScheduleItem(
						slot.getLessonNumber(),
						slot.getSlotType().name(),
						sessionFor(slot).name(),
						slot.getTitle(),
						"Tiết " + slot.getLessonNumber(),
						formatTimeRange(slot.getStartsAt(), slot.getEndsAt()),
						slot.getRoomName(),
						slot.getTeacherName()
				))
				.toList();
	}

	private Semester currentSemester(Student student) {
		return semesterRepository
				.findFirstByAcademicYearAndCurrentSemesterTrue(student.getSchoolClass().getAcademicYear())
				.orElseThrow(() -> new IllegalStateException("Current semester was not configured"));
	}

	private LocalDate normalizeWeekStart(LocalDate date) {
		return date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
	}

	private String dayLabel(DayOfWeek dayOfWeek) {
		return switch (dayOfWeek) {
			case MONDAY -> "Thứ hai";
			case TUESDAY -> "Thứ ba";
			case WEDNESDAY -> "Thứ tư";
			case THURSDAY -> "Thứ năm";
			case FRIDAY -> "Thứ sáu";
			case SATURDAY -> "Thứ bảy";
			case SUNDAY -> "Chủ nhật";
		};
	}

	private String dashboardSubtitle(ClassTimetableSlot slot) {
		if (slot.getSlotType() == ClassTimetableSlotType.MEAL) {
			if (slot.getRoomName() == null || slot.getRoomName().isBlank()) {
				return "Ăn trưa / nghỉ trưa";
			}
			return "Ăn trưa / nghỉ trưa - " + slot.getRoomName();
		}
		if (slot.getRoomName() == null || slot.getRoomName().isBlank()) {
			return "Tiết " + slot.getLessonNumber();
		}
		return "Tiết " + slot.getLessonNumber() + " - " + slot.getRoomName();
	}

	private ScheduleSession sessionFor(ClassTimetableSlot slot) {
		if (slot.getSlotType() == ClassTimetableSlotType.MEAL) {
			return ScheduleSession.NOON;
		}
		if (slot.getStartsAt().isBefore(LocalTime.of(12, 0))) {
			return ScheduleSession.MORNING;
		}
		return ScheduleSession.AFTERNOON;
	}

	private String formatTimeRange(LocalTime startsAt, LocalTime endsAt) {
		return formatTime(startsAt) + " - " + formatTime(endsAt);
	}

	private String formatTime(LocalTime time) {
		return time.format(TIME_FORMATTER);
	}
}
