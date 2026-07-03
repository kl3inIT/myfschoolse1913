package vn.edu.fpt.myfschoolse1913.club;

import java.util.List;
import java.util.UUID;

public record StudentClubsResponse(
		List<ClubItem> clubs
) {

	public record ClubItem(
			UUID id,
			String name,
			String description,
			String scheduleText,
			String location,
			String registrationStatus
	) {
	}
}
