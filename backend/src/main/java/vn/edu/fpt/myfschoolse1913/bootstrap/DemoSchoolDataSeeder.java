package vn.edu.fpt.myfschoolse1913.bootstrap;

import java.math.BigDecimal;
import java.time.LocalDate;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import vn.edu.fpt.myfschoolse1913.student.AcademicYear;
import vn.edu.fpt.myfschoolse1913.student.AcademicYearRepository;
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
			SemesterSubjectGradeRepository gradeRepository
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
}
