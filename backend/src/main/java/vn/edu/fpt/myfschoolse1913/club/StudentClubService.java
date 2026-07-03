package vn.edu.fpt.myfschoolse1913.club;

import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.student.CurrentStudentService;

@Service
public class StudentClubService {

	private final CurrentStudentService currentStudentService;
	private final SchoolClubRepository clubRepository;
	private final ClubRegistrationRepository registrationRepository;

	public StudentClubService(
			CurrentStudentService currentStudentService,
			SchoolClubRepository clubRepository,
			ClubRegistrationRepository registrationRepository
	) {
		this.currentStudentService = currentStudentService;
		this.clubRepository = clubRepository;
		this.registrationRepository = registrationRepository;
	}

	@Transactional(readOnly = true)
	public StudentClubsResponse getClubs(UUID userId) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var registrationsByClubId = registrationRepository.findByStudent(student).stream()
				.collect(Collectors.toMap(
						(registration) -> registration.getClub().getId(),
						Function.identity()
				));
		var clubs = clubRepository.findByActiveTrueOrderByNameAsc();

		return new StudentClubsResponse(
				clubs.stream()
						.map((club) -> toItem(club, registrationsByClubId.get(club.getId())))
						.toList()
		);
	}

	@Transactional
	public StudentClubsResponse.ClubItem register(UUID userId, UUID clubId) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var club = clubRepository.findByIdAndActiveTrue(clubId)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy câu lạc bộ"));
		var registration = registrationRepository.findByStudentAndClub(student, club)
				.orElseGet(() -> registrationRepository.save(new ClubRegistration(student, club)));

		return toItem(club, registration);
	}

	private StudentClubsResponse.ClubItem toItem(SchoolClub club, ClubRegistration registration) {
		return new StudentClubsResponse.ClubItem(
				club.getId(),
				club.getName(),
				club.getDescription(),
				club.getScheduleText(),
				club.getLocation(),
				registration == null ? null : registration.getStatus().name()
		);
	}
}
