package vn.edu.fpt.myfschoolse1913.event;

import java.time.Clock;
import java.time.Instant;
import java.util.Comparator;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.student.CurrentStudentService;

@Service
public class StudentEventService {

	private final CurrentStudentService currentStudentService;
	private final SchoolEventRepository eventRepository;
	private final Clock clock;

	public StudentEventService(
			CurrentStudentService currentStudentService,
			SchoolEventRepository eventRepository,
			Clock clock
	) {
		this.currentStudentService = currentStudentService;
		this.eventRepository = eventRepository;
		this.clock = clock;
	}

	@Transactional(readOnly = true)
	public StudentEventsResponse getEvents(UUID userId) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var schoolClass = student.getSchoolClass();
		var academicYear = schoolClass.getAcademicYear();
		var now = Instant.now(clock);
		var events = eventRepository.findVisibleEvents(academicYear, schoolClass);
		var items = events.stream()
				.map((event) -> toItem(event, now))
				.toList();
		var featuredEvent = items.stream()
				.filter((event) -> !"FINISHED".equals(event.status()))
				.min(Comparator.comparing(StudentEventsResponse.EventItem::startsAt))
				.orElse(items.isEmpty() ? null : items.get(0));

		return new StudentEventsResponse(featuredEvent, items);
	}

	private StudentEventsResponse.EventItem toItem(SchoolEvent event, Instant now) {
		return new StudentEventsResponse.EventItem(
				event.getId(),
				event.getTitle(),
				event.getDescription(),
				event.getLocation(),
				event.getStartsAt(),
				event.getEndsAt(),
				status(event, now)
		);
	}

	private String status(SchoolEvent event, Instant now) {
		if (now.isBefore(event.getStartsAt())) {
			return "UPCOMING";
		}
		if (now.isBefore(event.getEndsAt())) {
			return "ONGOING";
		}
		return "FINISHED";
	}
}
