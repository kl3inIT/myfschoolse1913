package vn.edu.fpt.myfschoolse1913.auth;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.user.AppUser;

@Entity
@Table(name = "password_reset_otps")
public class PasswordResetOtp {

	@Id
	@GeneratedValue
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	private AppUser user;

	@Column(name = "phone_number", nullable = false, length = 20)
	private String phoneNumber;

	@Column(name = "otp_hash", nullable = false, length = 64)
	private String otpHash;

	@Column(name = "reset_token_hash", unique = true, length = 64)
	private String resetTokenHash;

	@Column(name = "failed_attempts", nullable = false)
	private int failedAttempts;

	@Column(name = "expires_at", nullable = false)
	private Instant expiresAt;

	@Column(name = "reset_token_expires_at")
	private Instant resetTokenExpiresAt;

	@Column(name = "verified_at")
	private Instant verifiedAt;

	@Column(name = "consumed_at")
	private Instant consumedAt;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt = Instant.now();

	protected PasswordResetOtp() {
	}

	public PasswordResetOtp(AppUser user, String phoneNumber, String otpHash, Instant expiresAt) {
		this.user = user;
		this.phoneNumber = phoneNumber;
		this.otpHash = otpHash;
		this.expiresAt = expiresAt;
	}

	public Instant getCreatedAt() {
		return createdAt;
	}

	public AppUser getUser() {
		return user;
	}

	public boolean isOtpActive(Instant now, int maxVerifyAttempts) {
		return consumedAt == null && expiresAt.isAfter(now) && failedAttempts < maxVerifyAttempts;
	}

	public boolean isResetTokenActive(Instant now) {
		return consumedAt == null
				&& resetTokenHash != null
				&& resetTokenExpiresAt != null
				&& resetTokenExpiresAt.isAfter(now);
	}

	public boolean matchesOtpHash(String candidateOtpHash) {
		return otpHash.equals(candidateOtpHash);
	}

	public void registerFailedAttempt() {
		failedAttempts += 1;
	}

	public void verify(String resetTokenHash, Instant resetTokenExpiresAt, Instant now) {
		this.resetTokenHash = resetTokenHash;
		this.resetTokenExpiresAt = resetTokenExpiresAt;
		this.verifiedAt = now;
	}

	public void consume(Instant now) {
		this.consumedAt = now;
	}
}
