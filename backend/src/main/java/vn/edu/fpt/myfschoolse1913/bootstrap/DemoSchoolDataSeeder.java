package vn.edu.fpt.myfschoolse1913.bootstrap;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import vn.edu.fpt.myfschoolse1913.club.ClubRegistration;
import vn.edu.fpt.myfschoolse1913.club.ClubRegistrationRepository;
import vn.edu.fpt.myfschoolse1913.club.SchoolClub;
import vn.edu.fpt.myfschoolse1913.club.SchoolClubRepository;
import vn.edu.fpt.myfschoolse1913.application.StudentApplication;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationRepository;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationType;
import vn.edu.fpt.myfschoolse1913.event.SchoolEvent;
import vn.edu.fpt.myfschoolse1913.event.SchoolEventRepository;
import vn.edu.fpt.myfschoolse1913.student.AcademicYear;
import vn.edu.fpt.myfschoolse1913.student.AcademicYearRepository;
import vn.edu.fpt.myfschoolse1913.student.ClassTimetableSlot;
import vn.edu.fpt.myfschoolse1913.student.ClassTimetableSlotRepository;
import vn.edu.fpt.myfschoolse1913.student.ClassTimetableSlotType;
import vn.edu.fpt.myfschoolse1913.student.SchoolClass;
import vn.edu.fpt.myfschoolse1913.student.SchoolClassRepository;
import vn.edu.fpt.myfschoolse1913.student.Semester;
import vn.edu.fpt.myfschoolse1913.student.SemesterRepository;
import vn.edu.fpt.myfschoolse1913.student.SemesterSubjectGrade;
import vn.edu.fpt.myfschoolse1913.student.SemesterSubjectGradeRepository;
import vn.edu.fpt.myfschoolse1913.student.Student;
import vn.edu.fpt.myfschoolse1913.student.StudentRepository;
import vn.edu.fpt.myfschoolse1913.student.Subject;
import vn.edu.fpt.myfschoolse1913.student.SubjectRepository;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;

@Configuration
@ConditionalOnProperty(prefix = "app.bootstrap.demo-user", name = "enabled", havingValue = "true")
public class DemoSchoolDataSeeder {

	@Bean
	@Order(1)
	ApplicationRunner seedDemoSchoolData(
			AppUserRepository userRepository,
			AcademicYearRepository academicYearRepository,
			SchoolClassRepository schoolClassRepository,
			StudentRepository studentRepository,
			SemesterRepository semesterRepository,
			SubjectRepository subjectRepository,
			SemesterSubjectGradeRepository gradeRepository,
			ClassTimetableSlotRepository timetableSlotRepository,
			SchoolEventRepository eventRepository,
			StudentApplicationRepository applicationRepository,
			SchoolClubRepository clubRepository,
			ClubRegistrationRepository clubRegistrationRepository
	) {
		return (args) -> {
			var user = userRepository.findByPhoneNumber("0900000001")
					.orElseThrow(() -> new IllegalStateException("Demo user was not seeded"));

			var academicYear = academicYearRepository.findByName("Năm học 2026")
					.orElseGet(() -> academicYearRepository.save(new AcademicYear(
							"Năm học 2026",
							LocalDate.of(2026, 8, 1),
							LocalDate.of(2027, 5, 31),
							true
					)));

			var schoolClass = schoolClassRepository.findByAcademicYearAndName(academicYear, "Lớp 5A1")
					.orElseGet(() -> schoolClassRepository.save(new SchoolClass(academicYear, "Lớp 5A1")));

			var student = studentRepository.findByUserId(user.getId())
					.orElseGet(() -> studentRepository.save(new Student(
							user,
							schoolClass,
							"FS1913-0001",
							"Đang học"
					)));

			var semester = semesterRepository.findByAcademicYearAndName(academicYear, "Học kỳ 1")
					.orElseGet(() -> semesterRepository.save(new Semester(
							academicYear,
							"Học kỳ 1",
							1,
							LocalDate.of(2026, 8, 1),
							LocalDate.of(2026, 12, 31),
							true
					)));

			seedGrade(gradeRepository, student, semester, subject(subjectRepository, "MATH", "Toán học", 10), "8.5", "Miệng 8 - 15 phút 9 - Giữa kỳ 8");
			seedGrade(gradeRepository, student, semester, subject(subjectRepository, "VIETNAMESE", "Tiếng Việt", 20), "8.1", "Miệng 8 - 15 phút 8 - Giữa kỳ 8");
			seedGrade(gradeRepository, student, semester, subject(subjectRepository, "ENGLISH", "Tiếng Anh", 30), "8.7", "Miệng 9 - 15 phút 9 - Giữa kỳ 8");
			seedGrade(gradeRepository, student, semester, subject(subjectRepository, "SCIENCE", "Khoa học", 40), "8.3", "Miệng 8 - 15 phút 8 - Giữa kỳ 9");

			var math = subject(subjectRepository, "MATH", "Toán học", 10);
			var vietnamese = subject(subjectRepository, "VIETNAMESE", "Tiếng Việt", 20);
			var english = subject(subjectRepository, "ENGLISH", "Tiếng Anh", 30);
			var science = subject(subjectRepository, "SCIENCE", "Khoa học", 40);
			var music = subject(subjectRepository, "MUSIC", "Âm nhạc", 50);

			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 1, 1, math, "Phòng A203", "Cô Lan", "07:30", "08:05");
			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 1, 2, english, "Phòng B102", "Cô Hương", "08:25", "09:00");
			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 1, 3, music, "Phòng năng khiếu", "Thầy Nam", "09:25", "10:00");
			seedMealSlot(timetableSlotRepository, schoolClass, semester, 1, 4, "Ăn trưa", "Nhà ăn", "11:15", "12:00");

			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 2, 1, vietnamese, "Phòng A203", "Cô Mai", "07:30", "08:05");
			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 2, 2, science, "Phòng Lab 1", "Thầy Quân", "08:25", "09:00");
			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 2, 3, math, "Phòng A203", "Cô Lan", "09:25", "10:00");
			seedMealSlot(timetableSlotRepository, schoolClass, semester, 2, 4, "Ăn trưa", "Nhà ăn", "11:15", "12:00");

			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 3, 1, math, "Phòng A203", "Cô Lan", "07:30", "08:05");
			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 3, 2, english, "Phòng B102", "Cô Hương", "08:25", "09:00");
			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 3, 3, vietnamese, "Phòng A203", "Cô Mai", "09:25", "10:00");
			seedMealSlot(timetableSlotRepository, schoolClass, semester, 3, 4, "Ăn trưa", "Nhà ăn", "11:15", "12:00");

			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 4, 1, science, "Phòng Lab 1", "Thầy Quân", "07:30", "08:05");
			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 4, 2, math, "Phòng A203", "Cô Lan", "08:25", "09:00");
			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 4, 3, english, "Phòng B102", "Cô Hương", "09:25", "10:00");

			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 5, 1, vietnamese, "Phòng A203", "Cô Mai", "07:30", "08:05");
			seedSubjectSlot(timetableSlotRepository, schoolClass, semester, 5, 2, music, "Phòng năng khiếu", "Thầy Nam", "08:25", "09:00");

			seedEvent(
					eventRepository,
					academicYear,
					null,
					"Hội thao học sinh",
					"Hoạt động thể thao toàn trường với các nội dung chạy tiếp sức, kéo co và bóng rổ.",
					"Sân trường FPT Schools",
					atSchoolTime(2026, 7, 6, 8, 0),
					atSchoolTime(2026, 7, 6, 10, 30)
			);
			seedEvent(
					eventRepository,
					academicYear,
					schoolClass,
					"Sinh hoạt lớp cuối tuần",
					"Lớp tổng kết tuần học, nhận xét nề nếp và chuẩn bị kế hoạch tuần tiếp theo.",
					"Phòng A203",
					atSchoolTime(2026, 7, 10, 15, 0),
					atSchoolTime(2026, 7, 10, 15, 45)
			);
			seedEvent(
					eventRepository,
					academicYear,
					null,
					"Ngày hội câu lạc bộ",
					"Học sinh trải nghiệm các câu lạc bộ thể thao, nghệ thuật và STEM.",
					"Nhà đa năng",
					atSchoolTime(2026, 7, 12, 8, 30),
					atSchoolTime(2026, 7, 12, 11, 0)
			);
			seedEvent(
					eventRepository,
					academicYear,
					null,
					"Lễ tổng kết học kỳ",
					"Tổng kết hoạt động học kỳ, khen thưởng học sinh tiêu biểu và phổ biến kế hoạch mới.",
					"Hội trường",
					atSchoolTime(2026, 7, 25, 8, 0),
					atSchoolTime(2026, 7, 25, 9, 30)
			);

			seedApplication(
					applicationRepository,
					student,
					StudentApplicationType.ABSENCE,
					StudentApplicationStatus.PENDING,
					LocalDate.of(2026, 7, 1),
					null,
					"Em bị ốm cần nghỉ học một ngày",
					"Gia đình sẽ bổ sung giấy xác nhận nếu nhà trường yêu cầu."
			);
			seedApplication(
					applicationRepository,
					student,
					StudentApplicationType.EARLY_PICKUP,
					StudentApplicationStatus.APPROVED,
					LocalDate.of(2026, 7, 3),
					LocalTime.of(15, 30),
					"Gia đình có lịch khám sức khỏe",
					"Xin phép cho học sinh được ra về lúc 15:30."
			);
			seedApplication(
					applicationRepository,
					student,
					StudentApplicationType.MEAL_REGISTRATION,
					StudentApplicationStatus.APPROVED,
					LocalDate.of(2026, 7, 1),
					null,
					"Đăng ký suất ăn tháng 7",
					"Cập nhật thực đơn tháng 7"
			);

			var footballClub = seedClub(
					clubRepository,
					"CLB Bóng đá",
					"Rèn luyện thể lực và kỹ năng phối hợp đội nhóm.",
					"Thứ ba, thứ năm · Sân bóng",
					"Sân bóng"
			);
			seedClub(
					clubRepository,
					"CLB Mỹ thuật",
					"Vẽ, thủ công và sáng tạo sản phẩm nghệ thuật.",
					"Thứ tư · Phòng mỹ thuật",
					"Phòng mỹ thuật"
			);
			seedClub(
					clubRepository,
					"CLB Robotics",
					"Lắp ráp robot, lập trình cảm biến và thi đấu STEM.",
					"Thứ sáu · Phòng STEM",
					"Phòng STEM"
			);
			seedClub(
					clubRepository,
					"CLB Âm nhạc",
					"Hát, nhạc cụ và biểu diễn trong sự kiện trường.",
					"Thứ hai · Phòng năng khiếu",
					"Phòng năng khiếu"
			);
			seedClubRegistration(clubRegistrationRepository, student, footballClub);
		};
	}

	private Subject subject(SubjectRepository subjectRepository, String code, String name, int displayOrder) {
		return subjectRepository.findByCode(code)
				.map((subject) -> {
					if (subject.getDisplayOrder() != displayOrder) {
						subject.updateDisplayOrder(displayOrder);
						return subjectRepository.save(subject);
					}
					return subject;
				})
				.orElseGet(() -> subjectRepository.save(new Subject(code, name, displayOrder)));
	}

	private void seedGrade(
			SemesterSubjectGradeRepository gradeRepository,
			Student student,
			Semester semester,
			Subject subject,
			String averageScore,
			String detail
	) {
		gradeRepository.findByStudentAndSemesterAndSubject(student, semester, subject)
				.orElseGet(() -> gradeRepository.save(new SemesterSubjectGrade(
						student,
						semester,
						subject,
						new BigDecimal(averageScore),
						detail
				)));
	}

	private void seedSubjectSlot(
			ClassTimetableSlotRepository timetableSlotRepository,
			SchoolClass schoolClass,
			Semester semester,
			int dayIndex,
			int lessonNumber,
			Subject subject,
			String roomName,
			String teacherName,
			String startsAt,
			String endsAt
	) {
		seedSlot(
				timetableSlotRepository,
				schoolClass,
				semester,
				dayIndex,
				lessonNumber,
				ClassTimetableSlotType.SUBJECT,
				subject.getName(),
				subject,
				roomName,
				teacherName,
				startsAt,
				endsAt
		);
	}

	private void seedMealSlot(
			ClassTimetableSlotRepository timetableSlotRepository,
			SchoolClass schoolClass,
			Semester semester,
			int dayIndex,
			int lessonNumber,
			String title,
			String roomName,
			String startsAt,
			String endsAt
	) {
		seedSlot(
				timetableSlotRepository,
				schoolClass,
				semester,
				dayIndex,
				lessonNumber,
				ClassTimetableSlotType.MEAL,
				title,
				null,
				roomName,
				null,
				startsAt,
				endsAt
		);
	}

	private void seedSlot(
			ClassTimetableSlotRepository timetableSlotRepository,
			SchoolClass schoolClass,
			Semester semester,
			int dayIndex,
			int lessonNumber,
			ClassTimetableSlotType slotType,
			String title,
			Subject subject,
			String roomName,
			String teacherName,
			String startsAt,
			String endsAt
	) {
		timetableSlotRepository
				.findBySchoolClassAndSemesterAndDayIndexAndLessonNumber(
						schoolClass,
						semester,
						(short) dayIndex,
						lessonNumber
				)
				.orElseGet(() -> timetableSlotRepository.save(new ClassTimetableSlot(
						schoolClass,
						semester,
						dayIndex,
						lessonNumber,
						slotType,
						title,
						subject,
						roomName,
						teacherName,
						LocalTime.parse(startsAt),
						LocalTime.parse(endsAt)
				)));
	}

	private void seedEvent(
			SchoolEventRepository eventRepository,
			AcademicYear academicYear,
			SchoolClass schoolClass,
			String title,
			String description,
			String location,
			Instant startsAt,
			Instant endsAt
	) {
		eventRepository.findByTitleAndStartsAt(title, startsAt)
				.orElseGet(() -> eventRepository.save(new SchoolEvent(
						academicYear,
						schoolClass,
						title,
						description,
						location,
						startsAt,
						endsAt,
						true
				)));
	}

	private void seedApplication(
			StudentApplicationRepository applicationRepository,
			Student student,
			StudentApplicationType type,
			StudentApplicationStatus status,
			LocalDate targetDate,
			LocalTime requestedTime,
			String reason,
			String details
	) {
		applicationRepository.findByStudentAndTypeAndTargetDateAndReason(student, type, targetDate, reason)
				.orElseGet(() -> {
					var application = new StudentApplication(
							student,
							type,
							targetDate,
							requestedTime,
							reason,
							details
					);
					if (status == StudentApplicationStatus.APPROVED) {
						application.approve("Demo approval", atSchoolTime(2026, 7, 1, 8, 0));
					}
					if (status == StudentApplicationStatus.REJECTED) {
						application.reject("Demo rejection", atSchoolTime(2026, 7, 1, 8, 0));
					}
					return applicationRepository.save(application);
				});
	}

	private SchoolClub seedClub(
			SchoolClubRepository clubRepository,
			String name,
			String description,
			String scheduleText,
			String location
	) {
		return clubRepository.findByName(name)
				.orElseGet(() -> clubRepository.save(new SchoolClub(
						name,
						description,
						scheduleText,
						location,
						true
				)));
	}

	private void seedClubRegistration(
			ClubRegistrationRepository registrationRepository,
			Student student,
			SchoolClub club
	) {
		registrationRepository.findByStudentAndClub(student, club)
				.orElseGet(() -> {
					var registration = new ClubRegistration(student, club);
					registration.approve(atSchoolTime(2026, 7, 1, 8, 0));
					return registrationRepository.save(registration);
				});
	}

	private Instant atSchoolTime(int year, int month, int day, int hour, int minute) {
		return OffsetDateTime.of(year, month, day, hour, minute, 0, 0, ZoneOffset.ofHours(7)).toInstant();
	}
}
