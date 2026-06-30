package vn.edu.fpt.myfschoolse1913.auth;

import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.user.AppUser;
import vn.edu.fpt.myfschoolse1913.user.UserRole;

public record AuthResponse(
		String accessToken,
		String refreshToken,
		String tokenType,
		long expiresInSeconds,
		UserSummary user
) {

	static AuthResponse bearer(String accessToken, String refreshToken, long expiresInSeconds, AppUser user) {
		return new AuthResponse(
				accessToken,
				refreshToken,
				"Bearer",
				expiresInSeconds,
				UserSummary.from(user)
		);
	}

	public record UserSummary(
			UUID id,
			String phoneNumber,
			String fullName,
			UserRole role
	) {

		static UserSummary from(AppUser user) {
			return new UserSummary(user.getId(), user.getPhoneNumber(), user.getFullName(), user.getRole());
		}
	}
}
