package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface StudentGuardianRepository extends JpaRepository<StudentGuardian, UUID> {
  Optional<StudentGuardian> findByParentAndStudent(
      ParentProfile parent, vn.edu.fpt.myfschoolse1913.student.Student student);

  @Query(
      """
      select guardian from StudentGuardian guardian
      join fetch guardian.parent parent join fetch parent.user
      join fetch guardian.student student join fetch student.user
      join fetch student.schoolClass
      order by parent.user.fullName, student.user.fullName
      """)
  List<StudentGuardian> findAllWithDetails();

  @Query(
      """
      select guardian from StudentGuardian guardian
      join fetch guardian.student student join fetch student.user
      join fetch student.schoolClass schoolClass join fetch schoolClass.academicYear
      where guardian.parent = :parent and guardian.active = true
			order by student.studentCode
      """)
  List<StudentGuardian> findActiveByParent(@Param("parent") ParentProfile parent);

  @Query(
      """
      select guardian from StudentGuardian guardian
      join fetch guardian.student student join fetch student.user
      join fetch student.schoolClass schoolClass join fetch schoolClass.academicYear
      where guardian.parent = :parent and student.id = :studentId and guardian.active = true
      """)
  Optional<StudentGuardian> findActiveLink(
      @Param("parent") ParentProfile parent, @Param("studentId") UUID studentId);
}
