package vn.edu.fpt.myfschoolse1913.club;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SchoolClubRepository extends JpaRepository<SchoolClub, UUID> {

	List<SchoolClub> findByActiveTrueOrderByNameAsc();

	Optional<SchoolClub> findByIdAndActiveTrue(UUID id);

	Optional<SchoolClub> findByName(String name);
}
