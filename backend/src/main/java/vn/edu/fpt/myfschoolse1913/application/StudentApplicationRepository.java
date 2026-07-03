package vn.edu.fpt.myfschoolse1913.application;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.student.Student;

public interface StudentApplicationRepository extends JpaRepository<StudentApplication, UUID> {

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
