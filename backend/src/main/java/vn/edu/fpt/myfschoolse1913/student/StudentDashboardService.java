package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.shared.UnauthorizedException;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;
import vn.edu.fpt.myfschoolse1913.user.UserRole;

@Service
public class StudentDashboardService {

	private final AppUserRepository userRepository;

	public StudentDashboardService(AppUserRepository userRepository) {
		this.userRepository = userRepository;
	}

	@Transactional(readOnly = true)
	public StudentDashboardResponse getDashboard(UUID userId) {
		var user = userRepository.findById(userId)
				.filter((candidate) -> candidate.isEnabled() && candidate.getRole() == UserRole.STUDENT)
				.orElseThrow(() -> new UnauthorizedException("Student session is no longer valid"));

		return new StudentDashboardResponse(
				new StudentDashboardResponse.StudentSummary(
						user.getId(),
						user.getFullName(),
						user.getRole(),
						"Lớp 5A1",
						"Năm học 2026",
						"Đang học",
						initials(user.getFullName())
				),
				List.of(
						new StudentDashboardResponse.FeatureShortcut("SEMESTER_GRADES", "Điểm học kỳ"),
						new StudentDashboardResponse.FeatureShortcut("SCHEDULE", "Lịch học"),
						new StudentDashboardResponse.FeatureShortcut("EVENTS", "Sự kiện"),
						new StudentDashboardResponse.FeatureShortcut("APPLICATIONS", "Đơn từ"),
						new StudentDashboardResponse.FeatureShortcut("CLUBS", "CLB")
				),
				List.of(
						new StudentDashboardResponse.TodayScheduleItem("Toán học", "Tiết 1 - Phòng A203", "07:30"),
						new StudentDashboardResponse.TodayScheduleItem("Ăn trưa", "11:15 - Nhà ăn", "11:15")
				)
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
