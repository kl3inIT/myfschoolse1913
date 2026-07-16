package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentConductSummaryRepository
    extends JpaRepository<StudentConductSummary, UUID> {
  Optional<StudentConductSummary> findByStudentAndSemester(
      vn.edu.fpt.myfschoolse1913.student.Student student,
      vn.edu.fpt.myfschoolse1913.student.Semester semester);

  List<StudentConductSummary> findByStudentAndPublishedTrue(
      vn.edu.fpt.myfschoolse1913.student.Student student);
}
