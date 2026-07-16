package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TeachingAssignmentRepository extends JpaRepository<TeachingAssignment, UUID> {
  Optional<TeachingAssignment> findByTeacherAndSchoolClassAndSubjectAndSemesterAndType(
      TeacherProfile teacher,
      vn.edu.fpt.myfschoolse1913.student.SchoolClass schoolClass,
      vn.edu.fpt.myfschoolse1913.student.Subject subject,
      vn.edu.fpt.myfschoolse1913.student.Semester semester,
      TeachingAssignmentType type);

  @Query(
      """
      select assignment from TeachingAssignment assignment
      join fetch assignment.teacher teacher join fetch teacher.user
      join fetch assignment.schoolClass schoolClass join fetch schoolClass.academicYear
      join fetch assignment.subject join fetch assignment.semester
      order by teacher.user.fullName, schoolClass.name, assignment.subject.name
      """)
  List<TeachingAssignment> findAllWithDetails();

  @Query(
      """
      select assignment from TeachingAssignment assignment
      join fetch assignment.schoolClass schoolClass join fetch schoolClass.academicYear
      join fetch assignment.subject join fetch assignment.semester
      where assignment.teacher = :teacher and assignment.active = true
      order by schoolClass.name, assignment.subject.name
      """)
  List<TeachingAssignment> findActiveByTeacher(@Param("teacher") TeacherProfile teacher);

  @Query(
      """
      select assignment from TeachingAssignment assignment
      join fetch assignment.schoolClass schoolClass join fetch schoolClass.academicYear
      join fetch assignment.subject join fetch assignment.semester
      where assignment.id = :id and assignment.teacher = :teacher and assignment.active = true
      """)
  Optional<TeachingAssignment> findActiveOwned(
      @Param("id") UUID id, @Param("teacher") TeacherProfile teacher);

  List<TeachingAssignment> findBySchoolClassAndSemesterAndActiveTrue(
      vn.edu.fpt.myfschoolse1913.student.SchoolClass schoolClass,
      vn.edu.fpt.myfschoolse1913.student.Semester semester);
}
