package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface HomeroomAssignmentRepository extends JpaRepository<HomeroomAssignment, UUID> {
  Optional<HomeroomAssignment> findByTeacherAndSchoolClassAndAcademicYear(
      TeacherProfile teacher,
      vn.edu.fpt.myfschoolse1913.student.SchoolClass schoolClass,
      vn.edu.fpt.myfschoolse1913.student.AcademicYear year);

  Optional<HomeroomAssignment> findBySchoolClassAndAcademicYearAndActiveTrue(
      vn.edu.fpt.myfschoolse1913.student.SchoolClass schoolClass,
      vn.edu.fpt.myfschoolse1913.student.AcademicYear year);

  @Query(
      """
      select assignment from HomeroomAssignment assignment
      join fetch assignment.teacher teacher join fetch teacher.user
      join fetch assignment.schoolClass schoolClass join fetch assignment.academicYear
      order by teacher.user.fullName, schoolClass.name
      """)
  List<HomeroomAssignment> findAllWithDetails();

  @Query(
      """
      select assignment from HomeroomAssignment assignment
      join fetch assignment.schoolClass schoolClass join fetch assignment.academicYear
      where assignment.teacher = :teacher and assignment.active = true
      order by schoolClass.name
      """)
  List<HomeroomAssignment> findActiveByTeacher(@Param("teacher") TeacherProfile teacher);

  @Query(
      "select assignment from HomeroomAssignment assignment where assignment.teacher = :teacher and"
          + " assignment.schoolClass.id = :classId and assignment.active = true")
  Optional<HomeroomAssignment> findActiveOwnedClass(
      @Param("teacher") TeacherProfile teacher, @Param("classId") UUID classId);
}
