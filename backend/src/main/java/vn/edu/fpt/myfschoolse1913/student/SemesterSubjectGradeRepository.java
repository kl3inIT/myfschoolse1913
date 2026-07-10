package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

public interface SemesterSubjectGradeRepository extends JpaRepository<SemesterSubjectGrade, UUID> {

	@Query(
			value = """
					select grade
					from SemesterSubjectGrade grade
					join fetch grade.student student
					join fetch student.user user
					join fetch student.schoolClass schoolClass
					join fetch grade.subject subject
					join fetch grade.semester semester
					join fetch semester.academicYear academicYear
					where :search = ''
						or lower(student.studentCode) like concat('%', :search, '%')
						or lower(user.fullName) like concat('%', :search, '%')
						or lower(schoolClass.name) like concat('%', :search, '%')
						or lower(subject.code) like concat('%', :search, '%')
						or lower(subject.name) like concat('%', :search, '%')
					""",
			countQuery = """
					select count(grade)
					from SemesterSubjectGrade grade
					join grade.student student
					join student.user user
					join student.schoolClass schoolClass
					join grade.subject subject
					where :search = ''
						or lower(student.studentCode) like concat('%', :search, '%')
						or lower(user.fullName) like concat('%', :search, '%')
						or lower(schoolClass.name) like concat('%', :search, '%')
						or lower(subject.code) like concat('%', :search, '%')
						or lower(subject.name) like concat('%', :search, '%')
					"""
	)
	Page<SemesterSubjectGrade> searchForAdmin(@Param("search") String search, Pageable pageable);

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

	@Transactional
	void deleteByStudentAndSemester(Student student, Semester semester);
}
