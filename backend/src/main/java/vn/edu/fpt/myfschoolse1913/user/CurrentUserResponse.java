package vn.edu.fpt.myfschoolse1913.user;

import java.util.UUID;

public record CurrentUserResponse(
		UUID id,
		String phoneNumber,
		String fullName,
		UserRole role
) {

	public static CurrentUserResponse from(AppUser user) {
		return new CurrentUserResponse(
				user.getId(),
				user.getPhoneNumber(),
				user.getFullName(),
				user.getRole()
		);
	}
}
