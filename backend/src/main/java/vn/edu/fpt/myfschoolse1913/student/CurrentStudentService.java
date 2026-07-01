package vn.edu.fpt.myfschoolse1913.student;

import java.util.UUID;
import org.springframework.stereotype.Service;
import vn.edu.fpt.myfschoolse1913.shared.UnauthorizedException;
import vn.edu.fpt.myfschoolse1913.user.UserRole;

@Service
public class CurrentStudentService {

	private final StudentRepository studentRepository;

	public CurrentStudentService(StudentRepository studentRepository) {
		this.studentRepository = studentRepository;
	}

	public Student requireCurrentStudent(UUID userId) {
		return studentRepository.findByUserIdWithClass(userId)
				.filter((candidate) ->
						candidate.getUser().isEnabled() && candidate.getUser().getRole() == UserRole.STUDENT
				)
				.orElseThrow(() -> new UnauthorizedException("Phiên học sinh không hợp lệ. Vui lòng đăng nhập lại"));
	}
}
