package vn.edu.fpt.myfschoolse1913.student;

import java.util.Locale;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.student.AdminGradeListResponse.Item;

@Service
public class AdminGradeListService {

	private static final int MAX_PAGE_SIZE = 200;

	private final SemesterSubjectGradeRepository gradeRepository;

	public AdminGradeListService(SemesterSubjectGradeRepository gradeRepository) {
		this.gradeRepository = gradeRepository;
	}

	@Transactional(readOnly = true)
	public AdminGradeListResponse listGrades(String search, int page, int size) {
		var safePage = Math.max(page, 0);
		var safeSize = Math.min(Math.max(size, 1), MAX_PAGE_SIZE);
		var normalizedSearch = search == null ? "" : search.trim().toLowerCase(Locale.ROOT);
		var pageable = PageRequest.of(safePage, safeSize, Sort.by("updatedAt").descending());

		var result = gradeRepository.searchForAdmin(normalizedSearch, pageable);
		var items = result.getContent().stream().map(this::toItem).toList();

		return new AdminGradeListResponse(
				safePage,
				safeSize,
				result.getTotalElements(),
				result.getTotalPages(),
				items
		);
	}

	private Item toItem(SemesterSubjectGrade grade) {
		var student = grade.getStudent();
		var semester = grade.getSemester();
		return new Item(
				grade.getId(),
				student.getStudentCode(),
				student.getUser().getFullName(),
				student.getSchoolClass().getName(),
				semester.getAcademicYear().getName(),
				semester.getName(),
				grade.getSubject().getCode(),
				grade.getSubject().getName(),
				grade.getFormativeScore(),
				grade.getMidtermScore(),
				grade.getFinalScore(),
				grade.getAverageScore(),
				grade.getTeacherComment(),
				grade.getUpdatedAt()
		);
	}
}
