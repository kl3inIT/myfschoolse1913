package vn.edu.fpt.myfschoolse1913.student;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface SubjectRepository extends JpaRepository<Subject, UUID> {

	Optional<Subject> findByCode(String code);

	@Query("select coalesce(max(subject.displayOrder), 0) from Subject subject")
	int maxDisplayOrder();
}
