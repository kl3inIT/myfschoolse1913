package vn.edu.fpt.myfschoolse1913.student;

import java.time.LocalDate;
import java.util.List;

public record StudentScheduleResponse(
		LocalDate weekStart,
		LocalDate today,
		List<ScheduleDay> days
) {

	public record ScheduleDay(
			LocalDate date,
			String dayLabel,
			boolean today,
			List<ScheduleItem> items
	) {
	}

	public record ScheduleItem(
			int lessonNumber,
			String title,
			String lessonLabel,
			String timeRange,
			String roomName,
			String teacherName
	) {
	}
}
