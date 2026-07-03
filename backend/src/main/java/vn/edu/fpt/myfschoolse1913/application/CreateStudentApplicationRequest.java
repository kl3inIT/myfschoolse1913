package vn.edu.fpt.myfschoolse1913.application;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.time.LocalTime;

public record CreateStudentApplicationRequest(
		@NotNull(message = "Vui lòng chọn loại đơn")
		StudentApplicationType type,

		@NotNull(message = "Vui lòng chọn ngày áp dụng")
		LocalDate targetDate,

		LocalTime requestedTime,

		@NotBlank(message = "Vui lòng nhập lý do")
		@Size(max = 200, message = "Lý do tối đa 200 ký tự")
		String reason,

		@Size(max = 1000, message = "Nội dung chi tiết tối đa 1000 ký tự")
		String details
) {
}
