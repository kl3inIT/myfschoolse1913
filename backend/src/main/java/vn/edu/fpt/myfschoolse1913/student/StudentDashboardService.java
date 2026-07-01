package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StudentDashboardService {

	private final CurrentStudentService currentStudentService;
	private final StudentScheduleService scheduleService;

	public StudentDashboardService(CurrentStudentService currentStudentService, StudentScheduleService scheduleService) {
		this.currentStudentService = currentStudentService;
		this.scheduleService = scheduleService;
	}

	@Transactional(readOnly = true)
	public StudentDashboardResponse getDashboard(UUID userId) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var user = student.getUser();
		var schoolClass = student.getSchoolClass();
		var academicYear = schoolClass.getAcademicYear();

		return new StudentDashboardResponse(
				new StudentDashboardResponse.StudentSummary(
						user.getId(),
						user.getFullName(),
						user.getRole(),
						schoolClass.getName(),
						academicYear.getName(),
						student.getStatus(),
						initials(user.getFullName())
				),
				List.of(
						new StudentDashboardResponse.FeatureShortcut("SEMESTER_GRADES", "Điểm học kỳ"),
						new StudentDashboardResponse.FeatureShortcut("SCHEDULE", "Lịch học"),
						new StudentDashboardResponse.FeatureShortcut("EVENTS", "Sự kiện"),
						new StudentDashboardResponse.FeatureShortcut("APPLICATIONS", "Đơn từ"),
						new StudentDashboardResponse.FeatureShortcut("CLUBS", "CLB")
				),
				scheduleService.getTodayScheduleItems(student)
		);
	}

	private String initials(String fullName) {
		var parts = fullName.trim().split("\\s+");
		if (parts.length == 0) {
			return "?";
		}
		if (parts.length == 1) {
			return parts[0].substring(0, 1).toUpperCase();
		}
		return (parts[parts.length - 2].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
	}
}
