package vn.edu.fpt.myfschoolse1913.student;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SubjectRepository extends JpaRepository<Subject, UUID> {

	Optional<Subject> findByCode(String code);
}
