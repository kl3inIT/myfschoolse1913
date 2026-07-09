package vn.edu.fpt.myfschoolse1913.student;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.student.AdminStudentImportResponse.RowResult;
import vn.edu.fpt.myfschoolse1913.student.AdminStudentImportResponse.RowStatus;
import vn.edu.fpt.myfschoolse1913.user.AppUser;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;
import vn.edu.fpt.myfschoolse1913.user.UserRole;

@Service
public class StudentImportService {

	private static final String DEFAULT_STATUS = "Đang học";

	private final AppUserRepository userRepository;
	private final AcademicYearRepository academicYearRepository;
	private final SchoolClassRepository schoolClassRepository;
	private final StudentRepository studentRepository;
	private final PasswordEncoder passwordEncoder;

	public StudentImportService(
			AppUserRepository userRepository,
			AcademicYearRepository academicYearRepository,
			SchoolClassRepository schoolClassRepository,
			StudentRepository studentRepository,
			PasswordEncoder passwordEncoder
	) {
		this.userRepository = userRepository;
		this.academicYearRepository = academicYearRepository;
		this.schoolClassRepository = schoolClassRepository;
		this.studentRepository = studentRepository;
		this.passwordEncoder = passwordEncoder;
	}

	@Transactional
	public AdminStudentImportResponse importStudents(AdminStudentImportRequest request) {
		var rows = new ArrayList<RowResult>();
		var seenPhones = new HashSet<String>();
		var seenStudentCodes = new HashSet<String>();
		var classCache = new HashMap<String, SchoolClass>();
		var createdUsers = 0;
		var createdStudents = 0;
		var updatedStudents = 0;
		var skippedRows = 0;

		for (var index = 0; index < request.students().size(); index += 1) {
			var rowNumber = index + 1;
			var row = request.students().get(index);
			var phoneNumber = normalize(row.phoneNumber());
			var fullName = normalize(row.fullName());
			var studentCode = normalize(row.studentCode());

			if (!seenPhones.add(phoneNumber)) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, phoneNumber, studentCode, "Trùng số điện thoại trong file import"));
				continue;
			}
			if (!seenStudentCodes.add(studentCode)) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, phoneNumber, studentCode, "Trùng mã học sinh trong file import"));
				continue;
			}

			var schoolClass = resolveClass(request, row, classCache);
			var status = optional(row.status(), DEFAULT_STATUS);
			var existingUser = userRepository.findByPhoneNumber(phoneNumber);
			if (existingUser.isPresent() && existingUser.get().getRole() != UserRole.STUDENT) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, phoneNumber, studentCode, "Số điện thoại đã thuộc tài khoản không phải STUDENT"));
				continue;
			}

			var existingStudent = existingUser.flatMap((user) -> studentRepository.findByUserId(user.getId()));
			var existingStudentByCode = studentRepository.findByStudentCode(studentCode);
			if (existingStudentByCode.isPresent()
					&& (existingStudent.isEmpty() || !existingStudentByCode.get().getId().equals(existingStudent.get().getId()))) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, phoneNumber, studentCode, "Mã học sinh đã thuộc tài khoản khác"));
				continue;
			}

			var user = existingUser.orElseGet(() -> userRepository.save(new AppUser(
					phoneNumber,
					passwordEncoder.encode(optional(row.password(), request.defaultPassword())),
					fullName,
					UserRole.STUDENT
			)));
			if (existingUser.isEmpty()) {
				createdUsers += 1;
			}
			else {
				user.updateFullName(fullName);
				if (hasText(row.password())) {
					user.updatePasswordHash(passwordEncoder.encode(row.password().trim()));
				}
			}

			if (existingStudent.isPresent()) {
				var student = existingStudent.get();
				student.updateEnrollment(schoolClass, studentCode, status);
				updatedStudents += 1;
				rows.add(new RowResult(rowNumber, phoneNumber, studentCode, RowStatus.UPDATED, "Đã cập nhật học sinh"));
				continue;
			}

			studentRepository.save(new Student(user, schoolClass, studentCode, status));
			createdStudents += 1;
			rows.add(new RowResult(rowNumber, phoneNumber, studentCode, RowStatus.CREATED, "Đã tạo tài khoản học sinh"));
		}

		return new AdminStudentImportResponse(
				request.students().size(),
				createdUsers,
				createdStudents,
				updatedStudents,
				skippedRows,
				rows
		);
	}

	private SchoolClass resolveClass(
			AdminStudentImportRequest request,
			AdminStudentImportRequest.StudentImportRow row,
			Map<String, SchoolClass> classCache
	) {
		var academicYearName = optional(row.academicYearName(), request.academicYearName());
		var className = optional(row.className(), request.className());
		var cacheKey = academicYearName + "::" + className;

		return classCache.computeIfAbsent(cacheKey, (key) -> {
			var academicYear = academicYearRepository.findByName(academicYearName)
					.orElseGet(() -> academicYearRepository.save(new AcademicYear(academicYearName, null, null, true)));
			return schoolClassRepository.findByAcademicYearAndName(academicYear, className)
					.orElseGet(() -> schoolClassRepository.save(new SchoolClass(academicYear, className)));
		});
	}

	private RowResult skipped(int rowNumber, String phoneNumber, String studentCode, String message) {
		return new RowResult(rowNumber, phoneNumber, studentCode, RowStatus.SKIPPED, message);
	}

	private String optional(String value, String fallback) {
		return hasText(value) ? value.trim() : fallback.trim();
	}

	private String normalize(String value) {
		return value.trim();
	}

	private boolean hasText(String value) {
		return value != null && !value.trim().isEmpty();
	}
}
