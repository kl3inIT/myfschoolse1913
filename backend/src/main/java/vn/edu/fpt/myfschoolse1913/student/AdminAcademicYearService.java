package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.student.AdminAcademicYearsResponse.SchoolClassItem;
import vn.edu.fpt.myfschoolse1913.student.AdminAcademicYearsResponse.Year;

@Service
public class AdminAcademicYearService {

	private final AcademicYearRepository academicYearRepository;
	private final SchoolClassRepository schoolClassRepository;
	private final StudentRepository studentRepository;

	public AdminAcademicYearService(
			AcademicYearRepository academicYearRepository,
			SchoolClassRepository schoolClassRepository,
			StudentRepository studentRepository
	) {
		this.academicYearRepository = academicYearRepository;
		this.schoolClassRepository = schoolClassRepository;
		this.studentRepository = studentRepository;
	}

	@Transactional(readOnly = true)
	public AdminAcademicYearsResponse listAcademicYears() {
		var countsByClassId = studentRepository.countStudentsByClass().stream()
				.collect(Collectors.toMap(ClassStudentCount::classId, ClassStudentCount::studentCount));
		var classesByYearId = schoolClassRepository.findAllByOrderByName().stream()
				.collect(Collectors.groupingBy((schoolClass) -> schoolClass.getAcademicYear().getId()));

		var years = academicYearRepository.findAllByOrderByCurrentYearDescNameDesc().stream()
				.map((year) -> toYear(year, classesByYearId, countsByClassId))
				.toList();

		return new AdminAcademicYearsResponse(years);
	}

	@Transactional
	public Year createAcademicYear(AdminAcademicYearRequest request) {
		var name = request.name().trim();
		if (academicYearRepository.findByName(name).isPresent()) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Năm học đã tồn tại");
		}

		if (request.currentYear()) {
			academicYearRepository.findByCurrentYearTrue()
					.forEach((year) -> year.updateCurrentYear(false));
		}

		var year = academicYearRepository.save(new AcademicYear(
				name,
				request.startsOn(),
				request.endsOn(),
				request.currentYear()
		));
		return toYear(year, Map.of(), Map.of());
	}

	@Transactional
	public SchoolClassItem createSchoolClass(UUID yearId, AdminSchoolClassRequest request) {
		var year = academicYearRepository.findById(yearId)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy năm học"));

		var name = request.name().trim();
		if (schoolClassRepository.findByAcademicYearAndName(year, name).isPresent()) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Lớp đã tồn tại trong năm học này");
		}

		var schoolClass = schoolClassRepository.save(new SchoolClass(year, name));
		return new SchoolClassItem(schoolClass.getId(), schoolClass.getName(), 0);
	}

	private Year toYear(
			AcademicYear year,
			Map<UUID, List<SchoolClass>> classesByYearId,
			Map<UUID, Long> countsByClassId
	) {
		var classes = classesByYearId.getOrDefault(year.getId(), List.of()).stream()
				.map((schoolClass) -> new SchoolClassItem(
						schoolClass.getId(),
						schoolClass.getName(),
						countsByClassId.getOrDefault(schoolClass.getId(), 0L)
				))
				.toList();

		return new Year(
				year.getId(),
				year.getName(),
				year.getStartsOn(),
				year.getEndsOn(),
				year.isCurrentYear(),
				classes
		);
	}
}
