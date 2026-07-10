package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public record AdminAcademicYearRequest(
		@NotBlank(message = "Vui lòng nhập tên năm học")
		@Size(max = 40, message = "Tên năm học tối đa 40 ký tự")
		String name,

		LocalDate startsOn,

		LocalDate endsOn,

		boolean currentYear
) {
}
