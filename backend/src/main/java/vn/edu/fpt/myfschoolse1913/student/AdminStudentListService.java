package vn.edu.fpt.myfschoolse1913.student;

import java.util.Locale;
import java.util.UUID;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.student.AdminStudentListResponse.Item;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;

@Service
public class AdminStudentListService {

	private static final int MAX_PAGE_SIZE = 200;

	private final StudentRepository studentRepository;
	private final AppUserRepository userRepository;
	private final AcademicYearRepository academicYearRepository;
	private final SchoolClassRepository schoolClassRepository;
	private final PasswordEncoder passwordEncoder;

	public AdminStudentListService(
			StudentRepository studentRepository,
			AppUserRepository userRepository,
			AcademicYearRepository academicYearRepository,
			SchoolClassRepository schoolClassRepository,
			PasswordEncoder passwordEncoder
	) {
		this.studentRepository = studentRepository;
		this.userRepository = userRepository;
		this.academicYearRepository = academicYearRepository;
		this.schoolClassRepository = schoolClassRepository;
		this.passwordEncoder = passwordEncoder;
	}

	@Transactional(readOnly = true)
	public Item getStudent(UUID id) {
		return studentRepository.findByIdForAdmin(id)
				.map(this::toItem)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy học sinh"));
	}

	@Transactional
	public Item updateStudent(UUID id, AdminStudentUpdateRequest request) {
		var student = studentRepository.findByIdForAdmin(id)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy học sinh"));

		var phoneNumber = request.phoneNumber().trim();
		var conflictingUser = userRepository.findByPhoneNumber(phoneNumber);
		if (conflictingUser.isPresent() && !conflictingUser.get().getId().equals(student.getUser().getId())) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Số điện thoại đã thuộc tài khoản khác");
		}

		var studentCode = request.studentCode().trim();
		var conflictingStudent = studentRepository.findByStudentCode(studentCode);
		if (conflictingStudent.isPresent() && !conflictingStudent.get().getId().equals(student.getId())) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Mã học sinh đã thuộc học sinh khác");
		}

		var academicYear = academicYearRepository.findByName(request.academicYearName().trim())
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy năm học"));
		var schoolClass = schoolClassRepository
				.findByAcademicYearAndName(academicYear, request.className().trim())
				.orElseGet(() -> schoolClassRepository.save(
						new SchoolClass(academicYear, request.className().trim())
				));

		var user = student.getUser();
		user.updateFullName(request.fullName().trim());
		user.updatePhoneNumber(phoneNumber);
		user.updateEnabled(request.accountEnabled());
		if (request.newPassword() != null && !request.newPassword().isBlank()) {
			user.updatePasswordHash(passwordEncoder.encode(request.newPassword()));
		}

		student.updateEnrollment(schoolClass, studentCode, request.status().trim());

		return toItem(student);
	}

	@Transactional(readOnly = true)
	public AdminStudentStatsResponse studentStats() {
		return studentRepository.adminStats();
	}

	@Transactional(readOnly = true)
	public AdminStudentListResponse listStudents(String search, int page, int size) {
		var safePage = Math.max(page, 0);
		var safeSize = Math.min(Math.max(size, 1), MAX_PAGE_SIZE);
		var normalizedSearch = search == null ? "" : search.trim().toLowerCase(Locale.ROOT);
		var pageable = PageRequest.of(safePage, safeSize, Sort.by("studentCode").ascending());

		var result = studentRepository.searchForAdmin(normalizedSearch, pageable);
		var items = result.getContent().stream().map(this::toItem).toList();

		return new AdminStudentListResponse(
				safePage,
				safeSize,
				result.getTotalElements(),
				result.getTotalPages(),
				items
		);
	}

	private Item toItem(Student student) {
		return new Item(
				student.getId(),
				student.getStudentCode(),
				student.getUser().getFullName(),
				student.getUser().getPhoneNumber(),
				student.getSchoolClass().getName(),
				student.getSchoolClass().getAcademicYear().getName(),
				student.getStatus(),
				student.getUser().isEnabled()
		);
	}
}
