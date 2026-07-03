package vn.edu.fpt.myfschoolse1913.club;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.fpt.myfschoolse1913.student.Student;

public interface ClubRegistrationRepository extends JpaRepository<ClubRegistration, UUID> {

	@EntityGraph(attributePaths = "club")
	List<ClubRegistration> findByStudent(Student student);

	Optional<ClubRegistration> findByStudentAndClub(Student student, SchoolClub club);
}
