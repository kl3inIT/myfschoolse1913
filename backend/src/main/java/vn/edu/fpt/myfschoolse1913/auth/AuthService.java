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
import vn.edu.fpt.myfschoolse1913.user.AppUser;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;

@Service
public class AuthService {

	private final AppUserRepository userRepository;
	private final RefreshTokenRepository refreshTokenRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtEncoder jwtEncoder;
	private final AuthProperties authProperties;
	private final SecureRandom secureRandom = new SecureRandom();
	private final Clock clock = Clock.systemUTC();

	public AuthService(
			AppUserRepository userRepository,
			RefreshTokenRepository refreshTokenRepository,
			PasswordEncoder passwordEncoder,
			JwtEncoder jwtEncoder,
			AuthProperties authProperties
	) {
		this.userRepository = userRepository;
		this.refreshTokenRepository = refreshTokenRepository;
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

	@Transactional(readOnly = true)
	public void requestPasswordReset(PasswordResetRequest request) {
		userRepository.findByPhoneNumber(request.phoneNumber().trim())
				.filter(AppUser::isEnabled);
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
