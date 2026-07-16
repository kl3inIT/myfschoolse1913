package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ParentProfileRepository extends JpaRepository<ParentProfile, UUID> {
  Optional<ParentProfile> findByUserId(UUID userId);

  @Query(
      "select parent from ParentProfile parent join fetch parent.user where parent.user.id ="
          + " :userId and parent.status = 'ACTIVE'")
  Optional<ParentProfile> findActiveByUserId(@Param("userId") UUID userId);
}
