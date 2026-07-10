package vn.edu.fpt.myfschoolse1913.application;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.student.Student;

public interface StudentApplicationRepository extends JpaRepository<StudentApplication, UUID> {

	@Query(
			value = """
					select application
					from StudentApplication application
					join fetch application.student student
					join fetch student.user user
					join fetch student.schoolClass schoolClass
					where (:status is null or application.status = :status)
						and (:search = ''
							or lower(student.studentCode) like concat('%', :search, '%')
							or lower(user.fullName) like concat('%', :search, '%')
							or lower(schoolClass.name) like concat('%', :search, '%')
							or lower(application.reason) like concat('%', :search, '%'))
					""",
			countQuery = """
					select count(application)
					from StudentApplication application
					join application.student student
					join student.user user
					join student.schoolClass schoolClass
					where (:status is null or application.status = :status)
						and (:search = ''
							or lower(student.studentCode) like concat('%', :search, '%')
							or lower(user.fullName) like concat('%', :search, '%')
							or lower(schoolClass.name) like concat('%', :search, '%')
							or lower(application.reason) like concat('%', :search, '%'))
					"""
	)
	Page<StudentApplication> searchForAdmin(
			@Param("search") String search,
			@Param("status") StudentApplicationStatus status,
			Pageable pageable
	);

	@Query("""
			select new vn.edu.fpt.myfschoolse1913.application.AdminApplicationStatsResponse(
				count(application),
				coalesce(sum(case when application.status = vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus.PENDING then 1L else 0L end), 0L),
				coalesce(sum(case when application.status = vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus.APPROVED then 1L else 0L end), 0L),
				coalesce(sum(case when application.status = vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus.REJECTED then 1L else 0L end), 0L)
			)
			from StudentApplication application
			""")
	AdminApplicationStatsResponse adminStats();

	List<StudentApplication> findByStudentOrderByCreatedAtDesc(Student student);

	List<StudentApplication> findByStudentAndStatusOrderByCreatedAtDesc(
			Student student,
			StudentApplicationStatus status
	);

	Optional<StudentApplication> findByStudentAndTypeAndTargetDateAndReason(
			Student student,
			StudentApplicationType type,
			LocalDate targetDate,
			String reason
	);

	@Transactional
	void deleteByStudent(Student student);
}
