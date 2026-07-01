package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.shared.UnauthorizedException;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;
import vn.edu.fpt.myfschoolse1913.user.UserRole;

@Service
public class StudentSemesterGradesService {

	private final AppUserRepository userRepository;

	public StudentSemesterGradesService(AppUserRepository userRepository) {
		this.userRepository = userRepository;
	}

	@Transactional(readOnly = true)
	public StudentSemesterGradesResponse getSemesterGrades(UUID userId) {
		userRepository.findById(userId)
				.filter((candidate) -> candidate.isEnabled() && candidate.getRole() == UserRole.STUDENT)
				.orElseThrow(() -> new UnauthorizedException("Student session is no longer valid"));

		return new StudentSemesterGradesResponse(
				"Học kỳ 1",
				8.4,
				"Giỏi",
				List.of(
						new StudentSemesterGradesResponse.SubjectGrade("Toán học", 8.5, "Miệng 8 - 15 phút 9 - Giữa kỳ 8"),
						new StudentSemesterGradesResponse.SubjectGrade("Tiếng Việt", 8.1, "Miệng 8 - 15 phút 8 - Giữa kỳ 8"),
						new StudentSemesterGradesResponse.SubjectGrade("Tiếng Anh", 8.7, "Miệng 9 - 15 phút 9 - Giữa kỳ 8"),
						new StudentSemesterGradesResponse.SubjectGrade("Khoa học", 8.3, "Miệng 8 - 15 phút 8 - Giữa kỳ 9")
				)
		);
	}
}
