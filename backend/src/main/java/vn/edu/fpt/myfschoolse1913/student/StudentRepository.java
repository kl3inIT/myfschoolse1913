package vn.edu.fpt.myfschoolse1913.student;

import java.util.Optional;
import java.util.UUID;
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
}
