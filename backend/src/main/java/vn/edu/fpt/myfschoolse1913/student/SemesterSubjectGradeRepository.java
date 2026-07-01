package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SemesterSubjectGradeRepository extends JpaRepository<SemesterSubjectGrade, UUID> {

	@Query("""
			select grade
			from SemesterSubjectGrade grade
			join fetch grade.subject subject
			where grade.student = :student and grade.semester = :semester
			order by subject.displayOrder, subject.name
			""")
	List<SemesterSubjectGrade> findByStudentAndSemesterWithSubject(
			@Param("student") Student student,
			@Param("semester") Semester semester
	);

	Optional<SemesterSubjectGrade> findByStudentAndSemesterAndSubject(Student student, Semester semester, Subject subject);
}
