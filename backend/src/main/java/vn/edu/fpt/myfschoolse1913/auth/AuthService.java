package vn.edu.fpt.myfschoolse1913.auth;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.security.AuthProperties;
import vn.edu.fpt.myfschoolse1913.shared.RateLimitExceededException;
import vn.edu.fpt.myfschoolse1913.user.AppUser;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;

@Service
public class AuthService {

	private final AppUserRepository userRepository;
	private final RefreshTokenRepository refreshTokenRepository;
	private final PasswordResetOtpRepository passwordResetOtpRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtEncoder jwtEncoder;
	private final AuthProperties authProperties;
	private final SecureRandom secureRandom = new SecureRandom();
	private final Clock clock = Clock.systemUTC();

	public AuthService(
			AppUserRepository userRepository,
			RefreshTokenRepository refreshTokenRepository,
			PasswordResetOtpRepository passwordResetOtpRepository,
			PasswordEncoder passwordEncoder,
			JwtEncoder jwtEncoder,
			AuthProperties authProperties
	) {
		this.userRepository = userRepository;
		this.refreshTokenRepository = refreshTokenRepository;
		this.passwordResetOtpRepository = passwordResetOtpRepository;
		this.passwordEncoder = passwordEncoder;
		this.jwtEncoder = jwtEncoder;
		this.authProperties = authProperties;
	}

	@Transactional
	public AuthResponse login(LoginRequest request) {
		var phoneNumber = request.phoneNumber().trim();
		var user = userRepository.findByPhoneNumber(phoneNumber)
				.filter(AppUser::isEnabled)
				.filter((candidate) -> passwordEncoder.matches(request.password(), candidate.getPasswordHash()))
				.orElseThrow(InvalidCredentialsException::new);

		return issueTokens(user);
	}

	@Transactional
	public AuthResponse refresh(RefreshTokenRequest request) {
		var now = Instant.now(clock);
		var existingToken = refreshTokenRepository.findByTokenHash(hashToken(request.refreshToken()))
				.filter((token) -> token.isActive(now))
				.orElseThrow(InvalidCredentialsException::new);

		existingToken.revoke(now);
		return issueTokens(existingToken.getUser());
	}

	@Transactional
	public void logout(RefreshTokenRequest request) {
		var now = Instant.now(clock);
		refreshTokenRepository.findByTokenHash(hashToken(request.refreshToken()))
				.ifPresent((token) -> token.revoke(now));
	}

	@Transactional
	public PasswordResetRequestResponse requestPasswordReset(PasswordResetRequest request) {
		var phoneNumber = request.phoneNumber().trim();
		var user = userRepository.findByPhoneNumber(phoneNumber)
				.filter(AppUser::isEnabled);

		if (user.isEmpty()) {
			return PasswordResetRequestResponse.accepted(null);
		}

		var now = Instant.now(clock);
		enforcePasswordResetRateLimit(phoneNumber, now);

		passwordResetOtpRepository.findByUserAndConsumedAtIsNull(user.get())
				.forEach((otp) -> otp.consume(now));

		var rawOtp = generateOtp();
		var otp = new PasswordResetOtp(
				user.get(),
				phoneNumber,
				hashToken(rawOtp),
				now.plus(authProperties.passwordResetOtpTtl())
		);
		passwordResetOtpRepository.save(otp);

		var debugOtp = authProperties.exposePasswordResetOtp() ? rawOtp : null;
		return PasswordResetRequestResponse.accepted(debugOtp);
	}

	@Transactional(noRollbackFor = InvalidCredentialsException.class)
	public PasswordResetVerifyResponse verifyPasswordResetOtp(PasswordResetVerifyRequest request) {
		var phoneNumber = request.phoneNumber().trim();
		var now = Instant.now(clock);
		var otp = passwordResetOtpRepository
				.findFirstByPhoneNumberAndConsumedAtIsNullOrderByCreatedAtDesc(phoneNumber)
				.filter((candidate) -> candidate.isOtpActive(now, authProperties.passwordResetMaxVerifyAttempts()))
				.orElseThrow(InvalidCredentialsException::new);

		if (!otp.matchesOtpHash(hashToken(request.otp().trim()))) {
			otp.registerFailedAttempt();
			throw new InvalidCredentialsException();
		}

		var resetToken = generateRefreshToken();
		otp.verify(
				hashToken(resetToken),
				now.plus(authProperties.passwordResetTokenTtl()),
				now
		);
		return new PasswordResetVerifyResponse(resetToken);
	}

	@Transactional
	public void confirmPasswordReset(PasswordResetConfirmRequest request) {
		var now = Instant.now(clock);
		var otp = passwordResetOtpRepository
				.findByResetTokenHashAndConsumedAtIsNull(hashToken(request.resetToken().trim()))
				.filter((candidate) -> candidate.isResetTokenActive(now))
				.orElseThrow(InvalidCredentialsException::new);

		otp.consume(now);
		otp.getUser().updatePasswordHash(passwordEncoder.encode(request.newPassword()));
	}

	private AuthResponse issueTokens(AppUser user) {
		var now = Instant.now(clock);
		var accessTokenExpiresAt = now.plus(authProperties.accessTokenTtl());
		var accessToken = createAccessToken(user, now, accessTokenExpiresAt);
		var rawRefreshToken = generateRefreshToken();
		var refreshToken = new RefreshToken(
				user,
				hashToken(rawRefreshToken),
				now.plus(authProperties.refreshTokenTtl())
		);

		refreshTokenRepository.save(refreshToken);

		return AuthResponse.bearer(
				accessToken,
				rawRefreshToken,
				authProperties.accessTokenTtl().toSeconds(),
				user
		);
	}

	private String createAccessToken(AppUser user, Instant issuedAt, Instant expiresAt) {
		var claims = JwtClaimsSet.builder()
				.issuer("myfschoolse1913")
				.issuedAt(issuedAt)
				.expiresAt(expiresAt)
				.subject(user.getId().toString())
				.claim("phoneNumber", user.getPhoneNumber())
				.claim("role", user.getRole().name())
				.build();

		return jwtEncoder.encode(JwtEncoderParameters.from(claims)).getTokenValue();
	}

	private String generateRefreshToken() {
		var bytes = new byte[64];
		secureRandom.nextBytes(bytes);
		return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
	}

	private String generateOtp() {
		return String.format("%06d", secureRandom.nextInt(1_000_000));
	}

	private void enforcePasswordResetRateLimit(String phoneNumber, Instant now) {
		var createdAfter = now.minus(authProperties.passwordResetRequestCooldown());
		var recentRequests = passwordResetOtpRepository.countByPhoneNumberAndCreatedAtAfter(phoneNumber, createdAfter);
		if (recentRequests > 0) {
			throw new RateLimitExceededException("Vui lòng chờ trước khi gửi lại mã xác thực");
		}

		var hourlyRequests = passwordResetOtpRepository.countByPhoneNumberAndCreatedAtAfter(
				phoneNumber,
				now.minusSeconds(3600)
		);
		if (hourlyRequests >= authProperties.passwordResetMaxRequestsPerHour()) {
			throw new RateLimitExceededException("Bạn đã yêu cầu quá nhiều mã xác thực. Vui lòng thử lại sau");
		}
	}

	private String hashToken(String token) {
		try {
			var digest = MessageDigest.getInstance("SHA-256");
			var bytes = digest.digest(token.getBytes(StandardCharsets.UTF_8));
			return HexFormat.of().formatHex(bytes);
		}
		catch (Exception exception) {
			throw new IllegalStateException("Could not hash refresh token", exception);
		}
	}
}
