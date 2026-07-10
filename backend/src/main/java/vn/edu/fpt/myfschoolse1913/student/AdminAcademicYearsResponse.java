package vn.edu.fpt.myfschoolse1913.student;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record AdminAcademicYearsResponse(List<Year> years) {

	public record Year(
			UUID id,
			String name,
			LocalDate startsOn,
			LocalDate endsOn,
			boolean currentYear,
			List<SchoolClassItem> classes
	) {
	}

	public record SchoolClassItem(
			UUID id,
			String name,
			long studentCount
	) {
	}
}
