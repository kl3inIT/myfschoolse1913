package vn.edu.fpt.myfschoolse1913.user;

import java.util.Optional;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppUserRepository extends JpaRepository<AppUser, UUID> {

	Optional<AppUser> findByPhoneNumber(String phoneNumber);

	List<AppUser> findByRoleOrderByFullName(UserRole role);
}
