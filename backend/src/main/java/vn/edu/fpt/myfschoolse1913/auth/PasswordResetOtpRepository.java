package vn.edu.fpt.myfschoolse1913.auth;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.fpt.myfschoolse1913.user.AppUser;

public interface PasswordResetOtpRepository extends JpaRepository<PasswordResetOtp, UUID> {

	long countByPhoneNumberAndCreatedAtAfter(String phoneNumber, Instant createdAfter);

	List<PasswordResetOtp> findByUserAndConsumedAtIsNull(AppUser user);

	Optional<PasswordResetOtp> findFirstByPhoneNumberAndConsumedAtIsNullOrderByCreatedAtDesc(String phoneNumber);

	Optional<PasswordResetOtp> findByResetTokenHashAndConsumedAtIsNull(String resetTokenHash);
}
