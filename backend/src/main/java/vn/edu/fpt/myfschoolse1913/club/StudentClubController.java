package vn.edu.fpt.myfschoolse1913.club;

import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/students/me/clubs")
public class StudentClubController {

	private final StudentClubService clubService;

	public StudentClubController(StudentClubService clubService) {
		this.clubService = clubService;
	}

	@GetMapping
	public StudentClubsResponse clubs(@AuthenticationPrincipal Jwt jwt) {
		return clubService.getClubs(UUID.fromString(jwt.getSubject()));
	}

	@PostMapping("/{clubId}/registrations")
	@ResponseStatus(HttpStatus.CREATED)
	public StudentClubsResponse.ClubItem register(
			@AuthenticationPrincipal Jwt jwt,
			@PathVariable UUID clubId
	) {
		return clubService.register(UUID.fromString(jwt.getSubject()), clubId);
	}
}
