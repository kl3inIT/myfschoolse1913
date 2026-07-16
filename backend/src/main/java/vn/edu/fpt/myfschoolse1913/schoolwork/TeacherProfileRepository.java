package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TeacherProfileRepository extends JpaRepository<TeacherProfile, UUID> {
  Optional<TeacherProfile> findByUserId(UUID userId);

  Optional<TeacherProfile> findByEmployeeCode(String employeeCode);

  @Query(
      "select teacher from TeacherProfile teacher join fetch teacher.user order by"
          + " teacher.user.fullName")
  List<TeacherProfile> findAllWithUser();

  @Query(
      "select teacher from TeacherProfile teacher join fetch teacher.user where teacher.user.id ="
          + " :userId and teacher.status = 'ACTIVE'")
  Optional<TeacherProfile> findActiveByUserId(@Param("userId") UUID userId);
}
