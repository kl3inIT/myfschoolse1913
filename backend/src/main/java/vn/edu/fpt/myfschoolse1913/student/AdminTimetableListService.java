package vn.edu.fpt.myfschoolse1913.student;

import java.time.format.DateTimeFormatter;
import java.util.Locale;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.student.AdminTimetableListResponse.Item;

@Service
public class AdminTimetableListService {

	private static final int MAX_PAGE_SIZE = 200;
	private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

	private final ClassTimetableSlotRepository timetableSlotRepository;

	public AdminTimetableListService(ClassTimetableSlotRepository timetableSlotRepository) {
		this.timetableSlotRepository = timetableSlotRepository;
	}

	@Transactional(readOnly = true)
	public AdminTimetableListResponse listSlots(String search, int page, int size) {
		var safePage = Math.max(page, 0);
		var safeSize = Math.min(Math.max(size, 1), MAX_PAGE_SIZE);
		var normalizedSearch = search == null ? "" : search.trim().toLowerCase(Locale.ROOT);
		var pageable = PageRequest.of(safePage, safeSize, Sort.by(
				Sort.Order.asc("schoolClass.name"),
				Sort.Order.asc("dayIndex"),
				Sort.Order.asc("lessonNumber")
		));

		var result = timetableSlotRepository.searchForAdmin(normalizedSearch, pageable);
		var items = result.getContent().stream().map(this::toItem).toList();

		return new AdminTimetableListResponse(
				safePage,
				safeSize,
				result.getTotalElements(),
				result.getTotalPages(),
				items
		);
	}

	private Item toItem(ClassTimetableSlot slot) {
		return new Item(
				slot.getId(),
				slot.getSchoolClass().getName(),
				slot.getSchoolClass().getAcademicYear().getName(),
				slot.getSemester().getName(),
				slot.getDayIndex(),
				slot.getLessonNumber(),
				slot.getSlotType().name(),
				slot.getTitle(),
				slot.getSubject() == null ? null : slot.getSubject().getCode(),
				slot.getRoomName(),
				slot.getTeacherName(),
				slot.getStartsAt().format(TIME_FORMATTER),
				slot.getEndsAt().format(TIME_FORMATTER),
				slot.getUpdatedAt()
		);
	}
}
