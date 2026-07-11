package vn.edu.fpt.myfschoolse1913.bootstrap;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import vn.edu.fpt.myfschoolse1913.application.StudentApplication;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationRepository;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationType;
import vn.edu.fpt.myfschoolse1913.club.ClubRegistration;
import vn.edu.fpt.myfschoolse1913.club.ClubRegistrationRepository;
import vn.edu.fpt.myfschoolse1913.club.SchoolClub;
import vn.edu.fpt.myfschoolse1913.club.SchoolClubRepository;
import vn.edu.fpt.myfschoolse1913.event.SchoolEvent;
import vn.edu.fpt.myfschoolse1913.event.SchoolEventRepository;
import vn.edu.fpt.myfschoolse1913.notification.SchoolNotification;
import vn.edu.fpt.myfschoolse1913.notification.SchoolNotificationAudience;
import vn.edu.fpt.myfschoolse1913.notification.SchoolNotificationCategory;
import vn.edu.fpt.myfschoolse1913.notification.SchoolNotificationRepository;
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

	private static final List<String> GRADED_SUBJECT_CODES = List.of(
			"MATH",
			"LITERATURE",
			"ENGLISH",
			"HISTORY",
			"PHYSICS",
			"CHEMISTRY",
			"INFORMATICS",
			"CIVIC_EDUCATION"
	);

	private static final Map<String, Double> DEMO_STUDENT_AVERAGES = Map.of(
			"MATH", 8.5,
			"LITERATURE", 8.1,
			"ENGLISH", 8.7,
			"HISTORY", 8.2,
			"PHYSICS", 8.3,
			"CHEMISTRY", 7.9,
			"INFORMATICS", 8.6,
			"CIVIC_EDUCATION", 8.0
	);

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
			SchoolNotificationRepository notificationRepository,
			StudentApplicationRepository applicationRepository,
			SchoolClubRepository clubRepository,
			ClubRegistrationRepository clubRegistrationRepository,
			Clock clock
	) {
		return (args) -> {
			LocalDate today = LocalDate.now(clock);
			var academicYear = academicYearRepository.findByName("2026-2027")
					.orElseGet(() -> academicYearRepository.save(new AcademicYear(
							"2026-2027",
							LocalDate.of(2026, 7, 1),
							LocalDate.of(2027, 5, 31),
							true
					)));

			Map<String, SchoolClass> classes = new LinkedHashMap<>();
			for (String className : List.of("10A1", "10A2", "11A1")) {
				classes.put(
						className,
						schoolClassRepository.findByAcademicYearAndName(academicYear, className)
								.orElseGet(() -> schoolClassRepository.save(new SchoolClass(academicYear, className)))
				);
			}

			var semester = semesterRepository.findByAcademicYearAndName(academicYear, "Học kỳ 1")
					.orElseGet(() -> semesterRepository.save(new Semester(
							academicYear,
							"Học kỳ 1",
							1,
							LocalDate.of(2026, 7, 1),
							LocalDate.of(2026, 12, 31),
							true
					)));

			Map<String, Subject> subjects = seedSubjects(subjectRepository);
			Map<Integer, Student> students = seedStudents(
					userRepository,
					studentRepository,
					classes
			);

			for (var fixture : DemoStudentFixtures.STUDENTS) {
				Student student = students.get(fixture.number());
				gradeRepository.deleteByStudentAndSemester(student, semester);
				seedGrades(gradeRepository, student, semester, subjects, fixture.number());
				applicationRepository.deleteByStudent(student);
			}

			for (SchoolClass schoolClass : classes.values()) {
				timetableSlotRepository.deleteBySchoolClassAndSemester(schoolClass, semester);
				seedTimetable(timetableSlotRepository, schoolClass, semester, subjects);
			}

			eventRepository.deleteAllInBatch();
			notificationRepository.deleteAllInBatch();
			clubRegistrationRepository.deleteAllInBatch();
			seedEvents(eventRepository, academicYear, classes.get("10A1"), today, clock);
			seedNotifications(notificationRepository, today, clock);
			seedApplications(applicationRepository, students, today, clock);
			seedClubs(clubRepository, clubRegistrationRepository, students, clock);
		};
	}

	private Map<Integer, Student> seedStudents(
			AppUserRepository userRepository,
			StudentRepository studentRepository,
			Map<String, SchoolClass> classes
	) {
		Map<Integer, Student> students = new LinkedHashMap<>();
		for (var fixture : DemoStudentFixtures.STUDENTS) {
			var user = userRepository.findByPhoneNumber(fixture.phoneNumber())
					.orElseThrow(() -> new IllegalStateException(
							"Demo user was not seeded: " + fixture.phoneNumber()));
			SchoolClass schoolClass = classes.get(fixture.className());
			var student = studentRepository.findByUserId(user.getId())
					.orElseGet(() -> studentRepository.save(new Student(
							user,
							schoolClass,
							fixture.studentCode(),
							fixture.status()
					)));
			student.updateEnrollment(schoolClass, fixture.studentCode(), fixture.status());
			students.put(fixture.number(), studentRepository.save(student));
		}
		return students;
	}

	private Map<String, Subject> seedSubjects(SubjectRepository repository) {
		Map<String, Subject> subjects = new LinkedHashMap<>();
		List<SubjectFixture> fixtures = List.of(
				new SubjectFixture("MATH", "Toán học", 10),
				new SubjectFixture("LITERATURE", "Ngữ văn", 20),
				new SubjectFixture("ENGLISH", "Tiếng Anh", 30),
				new SubjectFixture("HISTORY", "Lịch sử", 40),
				new SubjectFixture("GEOGRAPHY", "Địa lý", 50),
				new SubjectFixture("PHYSICS", "Vật lý", 60),
				new SubjectFixture("CHEMISTRY", "Hóa học", 70),
				new SubjectFixture("BIOLOGY", "Sinh học", 80),
				new SubjectFixture("TECHNOLOGY", "Công nghệ", 90),
				new SubjectFixture("INFORMATICS", "Tin học", 100),
				new SubjectFixture("CIVIC_EDUCATION", "Giáo dục kinh tế và pháp luật", 110),
				new SubjectFixture("MUSIC", "Âm nhạc", 120),
				new SubjectFixture("FINE_ARTS", "Mỹ thuật", 130),
				new SubjectFixture("PHYSICAL_EDUCATION", "Giáo dục thể chất", 140),
				new SubjectFixture("DEFENSE_EDUCATION", "Giáo dục quốc phòng và an ninh", 150),
				new SubjectFixture("CAREER_EXPERIENCE", "Hoạt động trải nghiệm, hướng nghiệp", 160),
				new SubjectFixture("PDP", "Phát triển cá nhân", 170),
				new SubjectFixture("CODING", "Coding và Robotics", 180)
		);
		for (var fixture : fixtures) {
			subjects.put(fixture.code(), subject(
					repository,
					fixture.code(),
					fixture.name(),
					fixture.displayOrder()
			));
		}
		return subjects;
	}

	private Subject subject(SubjectRepository repository, String code, String name, int displayOrder) {
		return repository.findByCode(code)
				.map((subject) -> {
					if (subject.getDisplayOrder() != displayOrder) {
						subject.updateDisplayOrder(displayOrder);
						return repository.save(subject);
					}
					return subject;
				})
				.orElseGet(() -> repository.save(new Subject(code, name, displayOrder)));
	}

	private void seedGrades(
			SemesterSubjectGradeRepository repository,
			Student student,
			Semester semester,
			Map<String, Subject> subjects,
			int studentNumber
	) {
		for (int index = 0; index < GRADED_SUBJECT_CODES.size(); index++) {
			String subjectCode = GRADED_SUBJECT_CODES.get(index);
			double targetAverage = studentNumber == 1
					? DEMO_STUDENT_AVERAGES.get(subjectCode)
					: 5.2 + ((studentNumber * 7 + index * 3) % 43) / 10.0;
			BigDecimal midterm = score(targetAverage - 0.1);
			BigDecimal finalScore = score(targetAverage);
			BigDecimal formative = score(targetAverage + 0.3);
			BigDecimal average = weightedAverage(formative, midterm, finalScore);
			repository.save(new SemesterSubjectGrade(
					student,
					semester,
					subjects.get(subjectCode),
					formative,
					midterm,
					finalScore,
					average,
					"TX %s · GK %s · CK %s".formatted(formative, midterm, finalScore),
					commentFor(average)
			));
		}
	}

	private BigDecimal score(double value) {
		return BigDecimal.valueOf(Math.clamp(value, 0.0, 10.0)).setScale(1, RoundingMode.HALF_UP);
	}

	private BigDecimal weightedAverage(BigDecimal formative, BigDecimal midterm, BigDecimal finalScore) {
		return formative
				.add(midterm.multiply(BigDecimal.TWO))
				.add(finalScore.multiply(BigDecimal.valueOf(3)))
				.divide(BigDecimal.valueOf(6), 1, RoundingMode.HALF_UP);
	}

	private String commentFor(BigDecimal average) {
		double value = average.doubleValue();
		if (value >= 8.5) {
			return "Nắm vững kiến thức và vận dụng tốt trong bài tập.";
		}
		if (value >= 7.0) {
			return "Tiến bộ ổn định, cần duy trì nhịp ôn tập.";
		}
		if (value >= 5.5) {
			return "Đạt yêu cầu, nên luyện thêm phần vận dụng.";
		}
		return "Cần trao đổi với giáo viên và lập kế hoạch phụ đạo.";
	}

	private void seedTimetable(
			ClassTimetableSlotRepository repository,
			SchoolClass schoolClass,
			Semester semester,
			Map<String, Subject> subjects
	) {
		String room = "Phòng " + schoolClass.getName();
		seedStudyDay(repository, schoolClass, semester, 1, room, subjects,
				List.of("MATH", "LITERATURE", "ENGLISH", "HISTORY", "INFORMATICS", "PHYSICAL_EDUCATION", "CAREER_EXPERIENCE"));
		seedStudyDay(repository, schoolClass, semester, 2, room, subjects,
				List.of("PHYSICS", "CHEMISTRY", "MATH", "CIVIC_EDUCATION", "CODING", "ENGLISH", "PDP"));
		seedStudyDay(repository, schoolClass, semester, 3, room, subjects,
				List.of("LITERATURE", "GEOGRAPHY", "BIOLOGY", "ENGLISH", "INFORMATICS", "DEFENSE_EDUCATION", "CAREER_EXPERIENCE"));
		seedStudyDay(repository, schoolClass, semester, 4, room, subjects,
				List.of("MATH", "TECHNOLOGY", "LITERATURE", "HISTORY", "ENGLISH", "PHYSICS", "PDP"));
		seedStudyDay(repository, schoolClass, semester, 5, room, subjects,
				List.of("CHEMISTRY", "MATH", "INFORMATICS", "CIVIC_EDUCATION", "BIOLOGY", "PHYSICAL_EDUCATION", "CAREER_EXPERIENCE"));

		seedSlot(repository, schoolClass, semester, 6, 1, ClassTimetableSlotType.ACTIVITY,
				"Sinh hoạt câu lạc bộ", null, "Nhà đa năng", "Ban chủ nhiệm CLB", "08:30", "10:00");
		seedSlot(repository, schoolClass, semester, 6, 2, ClassTimetableSlotType.ACTIVITY,
				"Dự án STEM cuối tuần", subjects.get("CODING"), "Phòng STEM", "Thầy Long", "10:15", "11:30");
		seedSlot(repository, schoolClass, semester, 7, 1, ClassTimetableSlotType.ACTIVITY,
				"Ngày hội trải nghiệm", null, "Sân trường", "Phòng Công tác học sinh", "08:30", "10:30");
	}

	private void seedStudyDay(
			ClassTimetableSlotRepository repository,
			SchoolClass schoolClass,
			Semester semester,
			int dayIndex,
			String room,
			Map<String, Subject> subjects,
			List<String> subjectCodes
	) {
		String[] starts = {"07:45", "08:40", "09:40", "10:35", "11:20", "13:30", "14:25", "15:20"};
		String[] ends = {"08:30", "09:25", "10:25", "11:20", "13:30", "14:15", "15:10", "16:00"};
		for (int lesson = 1; lesson <= 8; lesson++) {
			if (lesson == 5) {
				seedSlot(repository, schoolClass, semester, dayIndex, lesson, ClassTimetableSlotType.MEAL,
						"Ăn trưa và nghỉ trưa", null, "Nhà ăn", null, starts[lesson - 1], ends[lesson - 1]);
				continue;
			}
			int subjectIndex = lesson < 5 ? lesson - 1 : lesson - 2;
			Subject subject = subjects.get(subjectCodes.get(subjectIndex));
			ClassTimetableSlotType type = subject.getCode().equals("CAREER_EXPERIENCE")
					|| subject.getCode().equals("PDP")
					? ClassTimetableSlotType.ACTIVITY
					: ClassTimetableSlotType.SUBJECT;
			seedSlot(repository, schoolClass, semester, dayIndex, lesson, type,
					subject.getName(), subject, roomFor(subject, room), teacherFor(subject), starts[lesson - 1], ends[lesson - 1]);
		}
	}

	private String roomFor(Subject subject, String defaultRoom) {
		return switch (subject.getCode()) {
			case "PHYSICS" -> "Phòng Lab Vật lý";
			case "CHEMISTRY", "BIOLOGY" -> "Phòng Lab Khoa học";
			case "INFORMATICS" -> "Phòng Lab CNTT";
			case "CODING", "TECHNOLOGY" -> "Phòng STEM";
			case "PHYSICAL_EDUCATION", "DEFENSE_EDUCATION" -> "Nhà đa năng";
			case "PDP" -> "Phòng PDP";
			default -> defaultRoom;
		};
	}

	private String teacherFor(Subject subject) {
		return switch (subject.getCode()) {
			case "MATH" -> "Cô Lan";
			case "LITERATURE" -> "Cô Mai";
			case "ENGLISH" -> "Cô Hương";
			case "HISTORY", "GEOGRAPHY" -> "Thầy Minh";
			case "PHYSICS" -> "Thầy Quân";
			case "CHEMISTRY", "BIOLOGY" -> "Cô Thảo";
			case "INFORMATICS", "CODING", "TECHNOLOGY" -> "Thầy Long";
			case "CIVIC_EDUCATION" -> "Thầy Bình";
			case "PHYSICAL_EDUCATION", "DEFENSE_EDUCATION" -> "Thầy Nam";
			case "PDP", "CAREER_EXPERIENCE" -> "Cô Trang";
			default -> "Giáo viên bộ môn";
		};
	}

	private void seedSlot(
			ClassTimetableSlotRepository repository,
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
		repository.save(new ClassTimetableSlot(
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
		));
	}

	private void seedEvents(
			SchoolEventRepository repository,
			AcademicYear academicYear,
			SchoolClass demoClass,
			LocalDate today,
			Clock clock
	) {
		seedEvent(repository, academicYear, null, "Hội thao học sinh",
				"Thi đấu bóng rổ, kéo co và chạy tiếp sức giữa các lớp.", "Sân trường",
				today.minusDays(2), 8, 0, 10, 30, clock);
		seedEvent(repository, academicYear, null, "Ngày hội câu lạc bộ",
				"Học sinh trải nghiệm các câu lạc bộ thể thao, nghệ thuật và STEM.", "Nhà đa năng",
				today, 8, 30, 11, 0, clock);
		seedEvent(repository, academicYear, demoClass, "Sinh hoạt lớp và tư vấn học tập",
				"Lớp tổng kết tuần và trao đổi kế hoạch học tập cá nhân.", "Phòng 10A1",
				today.plusDays(2), 15, 20, 16, 20, clock);
		seedEvent(repository, academicYear, null, "Workshop an toàn số",
				"Hướng dẫn bảo vệ tài khoản, dữ liệu cá nhân và ứng xử trên mạng.", "Hội trường",
				today.plusDays(5), 14, 0, 16, 0, clock);
		seedEvent(repository, academicYear, null, "Ngày hội STEM và Robotics",
				"Trưng bày dự án khoa học, lập trình và robot của học sinh.", "Phòng STEM",
				today.plusDays(10), 8, 0, 11, 30, clock);
	}

	private void seedEvent(
			SchoolEventRepository repository,
			AcademicYear academicYear,
			SchoolClass schoolClass,
			String title,
			String description,
			String location,
			LocalDate date,
			int startHour,
			int startMinute,
			int endHour,
			int endMinute,
			Clock clock
	) {
		repository.save(new SchoolEvent(
				academicYear,
				schoolClass,
				title,
				description,
				location,
				atSchoolTime(date, startHour, startMinute, clock),
				atSchoolTime(date, endHour, endMinute, clock),
				true
		));
	}

	private void seedNotifications(SchoolNotificationRepository repository, LocalDate today, Clock clock) {
		seedNotification(repository, "Lịch hoạt động cuối tuần",
				"Ngày hội câu lạc bộ bắt đầu lúc 08:30 tại nhà đa năng. Học sinh có mặt trước 15 phút.",
				SchoolNotificationCategory.EVENT, today, true, clock);
		seedNotification(repository, "Mở cổng đăng ký câu lạc bộ",
				"Cổng đăng ký CLB mở trong 5 ngày. Mỗi học sinh chọn tối đa hai câu lạc bộ.",
				SchoolNotificationCategory.EVENT, today.minusDays(1), false, clock);
		seedNotification(repository, "Lịch kiểm tra giữa kỳ",
				"Lịch kiểm tra chi tiết đã được cập nhật. Học sinh kiểm tra phòng thi và thời gian trước ngày thi.",
				SchoolNotificationCategory.ACADEMIC, today.minusDays(2), true, clock);
		seedNotification(repository, "Cập nhật dịch vụ bán trú",
				"Thực đơn tuần mới và thời gian nghỉ trưa đã được cập nhật trên hệ thống.",
				SchoolNotificationCategory.SERVICE, today.minusDays(3), false, clock);
		seedNotification(repository, "Workshop an toàn số",
				"Đăng ký tham gia workshop tại mục Sự kiện trước 17:00 thứ Hai.",
				SchoolNotificationCategory.GENERAL, today.minusDays(5), false, clock);
		seedNotification(repository, "Nhắc cập nhật hồ sơ học sinh",
				"Học sinh kiểm tra số điện thoại và thông tin lớp trong mục Tài khoản.",
				SchoolNotificationCategory.GENERAL, today.minusDays(7), false, clock);
	}

	private void seedNotification(
			SchoolNotificationRepository repository,
			String title,
			String body,
			SchoolNotificationCategory category,
			LocalDate date,
			boolean pinned,
			Clock clock
	) {
		repository.save(new SchoolNotification(
				title,
				body,
				category,
				SchoolNotificationAudience.HIGH_SCHOOL,
				atSchoolTime(date, 7, 0, clock),
				pinned,
				true
		));
	}

	private void seedApplications(
			StudentApplicationRepository repository,
			Map<Integer, Student> students,
			LocalDate today,
			Clock clock
	) {
		seedApplication(repository, students.get(1), StudentApplicationType.ABSENCE,
				StudentApplicationStatus.PENDING, today.plusDays(1), null,
				"Em bị ốm cần nghỉ học một ngày", "Gia đình sẽ bổ sung giấy xác nhận nếu cần.", clock);
		seedApplication(repository, students.get(1), StudentApplicationType.EARLY_LEAVE,
				StudentApplicationStatus.APPROVED, today.plusDays(2), LocalTime.of(15, 30),
				"Em có lịch khám sức khỏe", "Xin phép ra về sau tiết học buổi chiều.", clock);
		seedApplication(repository, students.get(1), StudentApplicationType.LATE_ARRIVAL,
				StudentApplicationStatus.REJECTED, today.minusDays(1), LocalTime.of(8, 30),
				"Em dự kiến đến trường muộn", "Xin phép vào lớp từ tiết 2.", clock);
		seedApplication(repository, students.get(1), StudentApplicationType.DOCUMENT_REQUEST,
				StudentApplicationStatus.APPROVED, today.plusDays(3), null,
				"Em cần giấy xác nhận học sinh", "Dùng để bổ sung hồ sơ dự thi học thuật.", clock);

		for (int number = 2; number <= 14; number++) {
			StudentApplicationStatus status = switch (number % 3) {
				case 0 -> StudentApplicationStatus.APPROVED;
				case 1 -> StudentApplicationStatus.REJECTED;
				default -> StudentApplicationStatus.PENDING;
			};
			StudentApplicationType type = switch (number % 4) {
				case 0 -> StudentApplicationType.ABSENCE;
				case 1 -> StudentApplicationType.EARLY_LEAVE;
				case 2 -> StudentApplicationType.LATE_ARRIVAL;
				default -> StudentApplicationType.DOCUMENT_REQUEST;
			};
			seedApplication(repository, students.get(number), type, status,
					today.plusDays(number % 6 + 1), type == StudentApplicationType.DOCUMENT_REQUEST ? null : LocalTime.of(15, 0),
					"Đơn mẫu của học sinh %02d".formatted(number),
					"Dữ liệu synthetic phục vụ kiểm thử danh sách và quy trình duyệt đơn.", clock);
		}
	}

	private void seedApplication(
			StudentApplicationRepository repository,
			Student student,
			StudentApplicationType type,
			StudentApplicationStatus status,
			LocalDate targetDate,
			LocalTime requestedTime,
			String reason,
			String details,
			Clock clock
	) {
		var application = new StudentApplication(student, type, targetDate, requestedTime, reason, details);
		Instant reviewedAt = Instant.now(clock).minusSeconds(3600);
		if (status == StudentApplicationStatus.APPROVED) {
			application.approve("Đã xác nhận thông tin demo", reviewedAt);
		} else if (status == StudentApplicationStatus.REJECTED) {
			application.reject("Vui lòng bổ sung thông tin người giám hộ", reviewedAt);
		}
		repository.save(application);
	}

	private void seedClubs(
			SchoolClubRepository clubRepository,
			ClubRegistrationRepository registrationRepository,
			Map<Integer, Student> students,
			Clock clock
	) {
		Map<String, SchoolClub> clubs = new LinkedHashMap<>();
		clubs.put("football", seedClub(clubRepository, "CLB Bóng đá",
				"Rèn luyện thể lực, chiến thuật và tinh thần đội nhóm.", "Thứ ba, thứ năm · 16:10-17:30", "Sân bóng"));
		clubs.put("debate", seedClub(clubRepository, "CLB Tranh biện tiếng Anh",
				"Luyện phản biện và thuyết trình bằng tiếng Anh.", "Thứ tư · 16:10-17:20", "Phòng 10A1"));
		clubs.put("art", seedClub(clubRepository, "CLB Mỹ thuật",
				"Thiết kế poster và sản phẩm sáng tạo cho sự kiện trường.", "Thứ tư · 16:10-17:20", "Phòng Mỹ thuật"));
		clubs.put("robotics", seedClub(clubRepository, "CLB Robotics",
				"Lắp ráp robot, lập trình cảm biến và thi đấu STEM.", "Thứ sáu · 16:10-17:30", "Phòng STEM"));
		clubs.put("music", seedClub(clubRepository, "CLB Âm nhạc",
				"Tập luyện thanh nhạc, nhạc cụ và biểu diễn.", "Thứ hai · 16:10-17:20", "Phòng Năng khiếu"));
		clubs.put("media", seedClub(clubRepository, "CLB Truyền thông",
				"Chụp ảnh, quay dựng video và truyền thông sự kiện.", "Thứ năm · 16:10-17:20", "Phòng Studio"));
		clubs.put("basketball", seedClub(clubRepository, "CLB Bóng rổ",
				"Rèn kỹ thuật bóng rổ và tham gia giải liên trường.", "Thứ hai, thứ tư · 16:10-17:30", "Nhà đa năng"));
		clubs.put("coding", seedClub(clubRepository, "CLB Lập trình",
				"Xây dựng ứng dụng và luyện tư duy giải quyết vấn đề.", "Thứ bảy · 10:15-11:30", "Phòng Lab CNTT"));

		seedClubRegistration(registrationRepository, students.get(1), clubs.get("football"), clock);
		seedClubRegistration(registrationRepository, students.get(2), clubs.get("robotics"), clock);
		seedClubRegistration(registrationRepository, students.get(3), clubs.get("debate"), clock);
		seedClubRegistration(registrationRepository, students.get(13), clubs.get("music"), clock);
		seedClubRegistration(registrationRepository, students.get(25), clubs.get("basketball"), clock);
	}

	private SchoolClub seedClub(
			SchoolClubRepository repository,
			String name,
			String description,
			String scheduleText,
			String location
	) {
		return repository.findByName(name)
				.map((club) -> {
					club.updateDetails(description, scheduleText, location, true);
					return repository.save(club);
				})
				.orElseGet(() -> repository.save(new SchoolClub(
						name,
						description,
						scheduleText,
						location,
						true
				)));
	}

	private void seedClubRegistration(
			ClubRegistrationRepository repository,
			Student student,
			SchoolClub club,
			Clock clock
	) {
		var registration = new ClubRegistration(student, club);
		registration.approve(Instant.now(clock).minusSeconds(3600));
		repository.save(registration);
	}

	private Instant atSchoolTime(LocalDate date, int hour, int minute, Clock clock) {
		return date.atTime(hour, minute).atZone(clock.getZone()).toInstant();
	}

	private record SubjectFixture(String code, String name, int displayOrder) {
	}
}
