package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StudentSemesterGradesService {

	private final CurrentStudentService currentStudentService;
	private final SemesterRepository semesterRepository;
	private final SemesterSubjectGradeRepository gradeRepository;

	public StudentSemesterGradesService(
			CurrentStudentService currentStudentService,
			SemesterRepository semesterRepository,
			SemesterSubjectGradeRepository gradeRepository
	) {
		this.currentStudentService = currentStudentService;
		this.semesterRepository = semesterRepository;
		this.gradeRepository = gradeRepository;
	}

	@Transactional(readOnly = true)
	public StudentSemesterGradesResponse getSemesterGrades(UUID userId) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var semester = semesterRepository
				.findFirstByAcademicYearAndCurrentSemesterTrue(student.getSchoolClass().getAcademicYear())
				.orElseThrow(() -> new IllegalStateException("Current semester was not configured"));
		var grades = gradeRepository.findByStudentAndSemesterWithSubject(student, semester);
		var averageScore = averageScore(grades);

		return new StudentSemesterGradesResponse(
				semester.getName(),
				averageScore,
				rankFor(averageScore),
				grades.stream()
						.map((grade) -> new StudentSemesterGradesResponse.SubjectGrade(
								grade.getSubject().getName(),
								grade.getAverageScore().doubleValue(),
								grade.getDetail()
						))
						.toList()
		);
	}

	private double averageScore(List<SemesterSubjectGrade> grades) {
		if (grades.isEmpty()) {
			return 0;
		}

		var average = grades.stream()
				.mapToDouble((grade) -> grade.getAverageScore().doubleValue())
				.average()
				.orElse(0);
		return Math.round(average * 10.0) / 10.0;
	}

	private String rankFor(double averageScore) {
		if (averageScore >= 8.0) {
			return "Giỏi";
		}
		if (averageScore >= 6.5) {
			return "Khá";
		}
		if (averageScore >= 5.0) {
			return "Trung bình";
		}
		return "Cần cải thiện";
	}
}
