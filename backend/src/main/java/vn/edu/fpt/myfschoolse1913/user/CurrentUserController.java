package vn.edu.fpt.myfschoolse1913.user;

import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.edu.fpt.myfschoolse1913.shared.UnauthorizedException;

@RestController
@RequestMapping("/api/me")
public class CurrentUserController {

	private final AppUserRepository userRepository;

	public CurrentUserController(AppUserRepository userRepository) {
		this.userRepository = userRepository;
	}

	@GetMapping
	public CurrentUserResponse me(@AuthenticationPrincipal Jwt jwt) {
		var user = userRepository.findById(UUID.fromString(jwt.getSubject()))
				.filter(AppUser::isEnabled)
				.orElseThrow(() -> new UnauthorizedException("Session is no longer valid"));

		return CurrentUserResponse.from(user);
	}
}
