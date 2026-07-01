package vn.edu.fpt.myfschoolse1913.student;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SemesterRepository extends JpaRepository<Semester, UUID> {

	Optional<Semester> findByAcademicYearAndName(AcademicYear academicYear, String name);

	Optional<Semester> findFirstByAcademicYearAndCurrentSemesterTrue(AcademicYear academicYear);
}
