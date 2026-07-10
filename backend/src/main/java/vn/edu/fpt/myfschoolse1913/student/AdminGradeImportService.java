package vn.edu.fpt.myfschoolse1913.student;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.StringJoiner;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.student.AdminGradeImportRequest.GradeImportRow;
import vn.edu.fpt.myfschoolse1913.student.AdminGradeImportResponse.RowResult;
import vn.edu.fpt.myfschoolse1913.student.AdminGradeImportResponse.RowStatus;

@Service
public class AdminGradeImportService {

	private final AcademicYearRepository academicYearRepository;
	private final SemesterRepository semesterRepository;
	private final SubjectRepository subjectRepository;
	private final StudentRepository studentRepository;
	private final SemesterSubjectGradeRepository gradeRepository;

	public AdminGradeImportService(
			AcademicYearRepository academicYearRepository,
			SemesterRepository semesterRepository,
			SubjectRepository subjectRepository,
			StudentRepository studentRepository,
			SemesterSubjectGradeRepository gradeRepository
	) {
		this.academicYearRepository = academicYearRepository;
		this.semesterRepository = semesterRepository;
		this.subjectRepository = subjectRepository;
		this.studentRepository = studentRepository;
		this.gradeRepository = gradeRepository;
	}

	@Transactional
	public AdminGradeImportResponse importGrades(AdminGradeImportRequest request) {
		var academicYear = academicYearRepository.findByName(request.academicYearName().trim())
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy năm học"));
		var semester = resolveSemester(academicYear, request.semesterName().trim());

		var rows = new ArrayList<RowResult>();
		var seenKeys = new HashSet<String>();
		var createdGrades = 0;
		var updatedGrades = 0;
		var skippedRows = 0;

		for (var index = 0; index < request.grades().size(); index += 1) {
			var rowNumber = index + 1;
			var row = request.grades().get(index);
			var studentCode = row.studentCode().trim();
			var subjectCode = row.subjectCode().trim();

			if (!seenKeys.add(studentCode + "::" + subjectCode)) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, studentCode, subjectCode, "Trùng học sinh và môn trong file import"));
				continue;
			}

			var student = studentRepository.findByStudentCode(studentCode);
			if (student.isEmpty()) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, studentCode, subjectCode, "Không tìm thấy học sinh"));
				continue;
			}

			var subject = subjectRepository.findByCode(subjectCode);
			if (subject.isEmpty() && !hasText(row.subjectName())) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, studentCode, subjectCode, "Môn chưa tồn tại; cần cột subjectName để tạo mới"));
				continue;
			}

			var averageScore = resolveAverageScore(row);
			if (averageScore == null) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, studentCode, subjectCode, "Thiếu điểm: cần ít nhất một điểm thành phần hoặc điểm trung bình"));
				continue;
			}

			var resolvedSubject = subject.orElseGet(() -> subjectRepository.save(new Subject(
					subjectCode,
					row.subjectName().trim(),
					subjectRepository.maxDisplayOrder() + 1
			)));

			var detail = buildDetail(row, averageScore);
			var teacherComment = hasText(row.teacherComment()) ? row.teacherComment().trim() : null;
			var existingGrade = gradeRepository
					.findByStudentAndSemesterAndSubject(student.get(), semester, resolvedSubject);

			if (existingGrade.isPresent()) {
				existingGrade.get().updateScores(
						row.formativeScore(),
						row.midtermScore(),
						row.finalScore(),
						averageScore,
						detail,
						teacherComment
				);
				updatedGrades += 1;
				rows.add(new RowResult(rowNumber, studentCode, subjectCode, RowStatus.UPDATED, "Đã cập nhật điểm"));
				continue;
			}

			gradeRepository.save(new SemesterSubjectGrade(
					student.get(),
					semester,
					resolvedSubject,
					row.formativeScore(),
					row.midtermScore(),
					row.finalScore(),
					averageScore,
					detail,
					teacherComment
			));
			createdGrades += 1;
			rows.add(new RowResult(rowNumber, studentCode, subjectCode, RowStatus.CREATED, "Đã ghi điểm mới"));
		}

		return new AdminGradeImportResponse(
				request.grades().size(),
				createdGrades,
				updatedGrades,
				skippedRows,
				rows
		);
	}

	private Semester resolveSemester(AcademicYear academicYear, String semesterName) {
		return semesterRepository.findByAcademicYearAndName(academicYear, semesterName)
				.orElseGet(() -> {
					var firstSemesterOfYear = semesterRepository
							.findFirstByAcademicYearAndCurrentSemesterTrue(academicYear)
							.isEmpty();
					return semesterRepository.save(new Semester(
							academicYear,
							semesterName,
							1,
							null,
							null,
							firstSemesterOfYear
					));
				});
	}

	private BigDecimal resolveAverageScore(GradeImportRow row) {
		if (row.averageScore() != null) {
			return row.averageScore().setScale(1, RoundingMode.HALF_UP);
		}

		var weightedTotal = BigDecimal.ZERO;
		var weights = 0;
		if (row.formativeScore() != null) {
			weightedTotal = weightedTotal.add(row.formativeScore());
			weights += 1;
		}
		if (row.midtermScore() != null) {
			weightedTotal = weightedTotal.add(row.midtermScore().multiply(BigDecimal.valueOf(2)));
			weights += 2;
		}
		if (row.finalScore() != null) {
			weightedTotal = weightedTotal.add(row.finalScore().multiply(BigDecimal.valueOf(3)));
			weights += 3;
		}

		if (weights == 0) {
			return null;
		}
		return weightedTotal.divide(BigDecimal.valueOf(weights), 1, RoundingMode.HALF_UP);
	}

	private String buildDetail(GradeImportRow row, BigDecimal averageScore) {
		var joiner = new StringJoiner(" · ");
		if (row.formativeScore() != null) {
			joiner.add("TX " + stripScore(row.formativeScore()));
		}
		if (row.midtermScore() != null) {
			joiner.add("GK " + stripScore(row.midtermScore()));
		}
		if (row.finalScore() != null) {
			joiner.add("CK " + stripScore(row.finalScore()));
		}
		if (joiner.length() == 0) {
			return "Điểm tổng kết " + stripScore(averageScore);
		}
		return joiner.toString();
	}

	private String stripScore(BigDecimal value) {
		return value.stripTrailingZeros().toPlainString();
	}

	private RowResult skipped(int rowNumber, String studentCode, String subjectCode, String message) {
		return new RowResult(rowNumber, studentCode, subjectCode, RowStatus.SKIPPED, message);
	}

	private boolean hasText(String value) {
		return value != null && !value.trim().isEmpty();
	}
}
