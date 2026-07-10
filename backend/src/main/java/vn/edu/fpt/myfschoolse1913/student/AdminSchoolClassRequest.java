package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AdminSchoolClassRequest(
		@NotBlank(message = "Vui lòng nhập tên lớp")
		@Size(max = 40, message = "Tên lớp tối đa 40 ký tự")
		String name
) {
}
