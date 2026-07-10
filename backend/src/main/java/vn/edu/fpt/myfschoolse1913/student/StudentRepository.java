package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface StudentRepository extends JpaRepository<Student, UUID> {

	@Query("""
			select student
			from Student student
			join fetch student.user
			join fetch student.schoolClass schoolClass
			join fetch schoolClass.academicYear
			where student.user.id = :userId
			""")
	Optional<Student> findByUserIdWithClass(@Param("userId") UUID userId);

	Optional<Student> findByUserId(UUID userId);

	Optional<Student> findByStudentCode(String studentCode);

	@Query("""
			select student
			from Student student
			join fetch student.user
			join fetch student.schoolClass schoolClass
			join fetch schoolClass.academicYear
			where student.id = :id
			""")
	Optional<Student> findByIdForAdmin(@Param("id") UUID id);

	@Query(
			value = """
					select student
					from Student student
					join fetch student.user user
					join fetch student.schoolClass schoolClass
					join fetch schoolClass.academicYear
					where :search = ''
						or lower(student.studentCode) like concat('%', :search, '%')
						or lower(user.fullName) like concat('%', :search, '%')
						or user.phoneNumber like concat('%', :search, '%')
						or lower(schoolClass.name) like concat('%', :search, '%')
					""",
			countQuery = """
					select count(student)
					from Student student
					join student.user user
					join student.schoolClass schoolClass
					where :search = ''
						or lower(student.studentCode) like concat('%', :search, '%')
						or lower(user.fullName) like concat('%', :search, '%')
						or user.phoneNumber like concat('%', :search, '%')
						or lower(schoolClass.name) like concat('%', :search, '%')
					"""
	)
	Page<Student> searchForAdmin(@Param("search") String search, Pageable pageable);

	@Query("""
			select new vn.edu.fpt.myfschoolse1913.student.ClassStudentCount(
				student.schoolClass.id,
				count(student)
			)
			from Student student
			group by student.schoolClass.id
			""")
	List<ClassStudentCount> countStudentsByClass();

	@Query("""
			select new vn.edu.fpt.myfschoolse1913.student.AdminStudentStatsResponse(
				count(student),
				coalesce(sum(case when student.status = 'Đang học' then 1L else 0L end), 0L),
				coalesce(sum(case when student.user.enabled = false then 1L else 0L end), 0L),
				count(distinct student.schoolClass.id)
			)
			from Student student
			""")
	AdminStudentStatsResponse adminStats();
}
