package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SchoolClassRepository extends JpaRepository<SchoolClass, UUID> {

	Optional<SchoolClass> findByAcademicYearAndName(AcademicYear academicYear, String name);

	List<SchoolClass> findAllByOrderByName();
}
