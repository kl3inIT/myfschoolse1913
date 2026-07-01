package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.user.UserRole;

public record StudentDashboardResponse(
		StudentSummary student,
		List<FeatureShortcut> shortcuts,
		List<TodayScheduleItem> todaySchedule
) {

	public record StudentSummary(
			UUID id,
			String fullName,
			UserRole role,
			String className,
			String schoolYear,
			String status,
			String initials
	) {
	}

	public record FeatureShortcut(
			String code,
			String label
	) {
	}

	public record TodayScheduleItem(
			String title,
			String subtitle,
			String time
	) {
	}
}
