package vn.edu.fpt.myfschoolse1913.student;

import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Locale;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.student.AdminTimetableImportRequest.TimetableImportRow;
import vn.edu.fpt.myfschoolse1913.student.AdminTimetableImportResponse.RowResult;
import vn.edu.fpt.myfschoolse1913.student.AdminTimetableImportResponse.RowStatus;

@Service
public class AdminTimetableImportService {

	private final AcademicYearRepository academicYearRepository;
	private final SemesterRepository semesterRepository;
	private final SchoolClassRepository schoolClassRepository;
	private final SubjectRepository subjectRepository;
	private final ClassTimetableSlotRepository timetableSlotRepository;

	public AdminTimetableImportService(
			AcademicYearRepository academicYearRepository,
			SemesterRepository semesterRepository,
			SchoolClassRepository schoolClassRepository,
			SubjectRepository subjectRepository,
			ClassTimetableSlotRepository timetableSlotRepository
	) {
		this.academicYearRepository = academicYearRepository;
		this.semesterRepository = semesterRepository;
		this.schoolClassRepository = schoolClassRepository;
		this.subjectRepository = subjectRepository;
		this.timetableSlotRepository = timetableSlotRepository;
	}

	@Transactional
	public AdminTimetableImportResponse importTimetable(AdminTimetableImportRequest request) {
		var academicYear = academicYearRepository.findByName(request.academicYearName().trim())
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy năm học"));
		var semester = resolveSemester(academicYear, request.semesterName().trim());
		var defaultClassName = trimmedOrNull(request.defaultClassName());

		var rows = new ArrayList<RowResult>();
		var seenKeys = new HashSet<String>();
		var classCache = new HashMap<String, SchoolClass>();
		var createdSlots = 0;
		var updatedSlots = 0;
		var skippedRows = 0;

		for (var index = 0; index < request.slots().size(); index += 1) {
			var rowNumber = index + 1;
			var row = request.slots().get(index);
			var className = trimmedOrNull(row.className()) != null
					? row.className().trim()
					: defaultClassName;

			if (className == null) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, "", row, "Thiếu lớp: điền cột className hoặc lớp mặc định"));
				continue;
			}

			if (!seenKeys.add(className + "::" + row.dayIndex() + "::" + row.lessonNumber())) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, className, row, "Trùng lớp, thứ và tiết trong file import"));
				continue;
			}

			var slotType = resolveSlotType(row.slotType());
			if (slotType == null) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, className, row, "Loại tiết phải là SUBJECT, MEAL hoặc ACTIVITY"));
				continue;
			}

			var subjectCode = trimmedOrNull(row.subjectCode());
			Subject subject = null;
			if (subjectCode != null) {
				var existingSubject = subjectRepository.findByCode(subjectCode);
				if (existingSubject.isEmpty() && trimmedOrNull(row.subjectName()) == null) {
					skippedRows += 1;
					rows.add(skipped(rowNumber, className, row, "Môn chưa tồn tại; cần cột subjectName để tạo mới"));
					continue;
				}
				subject = existingSubject.orElseGet(() -> subjectRepository.save(new Subject(
						subjectCode,
						row.subjectName().trim(),
						subjectRepository.maxDisplayOrder() + 1
				)));
			}

			var title = trimmedOrNull(row.title()) != null
					? row.title().trim()
					: subject != null ? subject.getName() : null;
			if (title == null) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, className, row, "Thiếu tiêu đề: điền cột title hoặc subjectCode"));
				continue;
			}

			var startsAt = parseTime(row.startsAt());
			var endsAt = parseTime(row.endsAt());
			if (startsAt == null || endsAt == null) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, className, row, "Giờ phải theo định dạng HH:mm"));
				continue;
			}
			if (!endsAt.isAfter(startsAt)) {
				skippedRows += 1;
				rows.add(skipped(rowNumber, className, row, "Giờ kết thúc phải sau giờ bắt đầu"));
				continue;
			}

			var schoolClass = classCache.computeIfAbsent(className, (name) ->
					schoolClassRepository.findByAcademicYearAndName(academicYear, name)
							.orElseGet(() -> schoolClassRepository.save(new SchoolClass(academicYear, name)))
			);

			var roomName = trimmedOrNull(row.roomName());
			var teacherName = trimmedOrNull(row.teacherName());
			var existingSlot = timetableSlotRepository.findBySchoolClassAndSemesterAndDayIndexAndLessonNumber(
					schoolClass,
					semester,
					row.dayIndex().shortValue(),
					row.lessonNumber()
			);

			if (existingSlot.isPresent()) {
				existingSlot.get().updateDetails(slotType, title, subject, roomName, teacherName, startsAt, endsAt);
				updatedSlots += 1;
				rows.add(new RowResult(
						rowNumber, className, row.dayIndex(), row.lessonNumber(),
						RowStatus.UPDATED, "Đã cập nhật tiết học"
				));
				continue;
			}

			timetableSlotRepository.save(new ClassTimetableSlot(
					schoolClass,
					semester,
					row.dayIndex(),
					row.lessonNumber(),
					slotType,
					title,
					subject,
					roomName,
					teacherName,
					startsAt,
					endsAt
			));
			createdSlots += 1;
			rows.add(new RowResult(
					rowNumber, className, row.dayIndex(), row.lessonNumber(),
					RowStatus.CREATED, "Đã tạo tiết học mới"
			));
		}

		return new AdminTimetableImportResponse(
				request.slots().size(),
				createdSlots,
				updatedSlots,
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

	private ClassTimetableSlotType resolveSlotType(String slotType) {
		var trimmed = trimmedOrNull(slotType);
		if (trimmed == null) {
			return ClassTimetableSlotType.SUBJECT;
		}
		try {
			return ClassTimetableSlotType.valueOf(trimmed.toUpperCase(Locale.ROOT));
		} catch (IllegalArgumentException exception) {
			return null;
		}
	}

	private LocalTime parseTime(String value) {
		var trimmed = trimmedOrNull(value);
		if (trimmed == null) {
			return null;
		}
		try {
			return LocalTime.parse(trimmed);
		} catch (DateTimeParseException exception) {
			return null;
		}
	}

	private RowResult skipped(int rowNumber, String className, TimetableImportRow row, String message) {
		return new RowResult(
				rowNumber,
				className,
				row.dayIndex() == null ? 0 : row.dayIndex(),
				row.lessonNumber() == null ? 0 : row.lessonNumber(),
				RowStatus.SKIPPED,
				message
		);
	}

	private String trimmedOrNull(String value) {
		if (value == null || value.trim().isEmpty()) {
			return null;
		}
		return value.trim();
	}
}
