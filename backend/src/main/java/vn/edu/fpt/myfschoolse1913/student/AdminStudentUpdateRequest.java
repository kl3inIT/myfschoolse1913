package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AdminStudentUpdateRequest(
		@NotBlank(message = "Vui lòng nhập họ tên")
		@Size(max = 120, message = "Họ tên tối đa 120 ký tự")
		String fullName,

		@NotBlank(message = "Vui lòng nhập số điện thoại")
		@Size(max = 20, message = "Số điện thoại tối đa 20 ký tự")
		String phoneNumber,

		@NotBlank(message = "Vui lòng nhập mã học sinh")
		@Size(max = 40, message = "Mã học sinh tối đa 40 ký tự")
		String studentCode,

		@NotBlank(message = "Vui lòng nhập năm học")
		@Size(max = 40, message = "Năm học tối đa 40 ký tự")
		String academicYearName,

		@NotBlank(message = "Vui lòng nhập lớp")
		@Size(max = 40, message = "Lớp tối đa 40 ký tự")
		String className,

		@NotBlank(message = "Vui lòng nhập trạng thái")
		@Size(max = 40, message = "Trạng thái tối đa 40 ký tự")
		String status,

		boolean accountEnabled,

		@Size(min = 8, max = 100, message = "Mật khẩu mới phải từ 8 đến 100 ký tự")
		String newPassword
) {
}
