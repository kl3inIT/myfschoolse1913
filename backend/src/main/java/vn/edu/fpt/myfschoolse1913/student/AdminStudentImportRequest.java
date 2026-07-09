package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import java.util.List;

public record AdminStudentImportRequest(
		@NotBlank(message = "Vui lòng nhập năm học mặc định")
		@Size(max = 40, message = "Năm học tối đa 40 ký tự")
		String academicYearName,

		@NotBlank(message = "Vui lòng nhập lớp mặc định")
		@Size(max = 40, message = "Lớp tối đa 40 ký tự")
		String className,

		@NotBlank(message = "Vui lòng nhập mật khẩu mặc định")
		@Size(min = 8, max = 100, message = "Mật khẩu mặc định phải từ 8 đến 100 ký tự")
		String defaultPassword,

		@NotEmpty(message = "Danh sách học sinh không được trống")
		@Size(max = 500, message = "Mỗi lần import tối đa 500 học sinh")
		List<@Valid StudentImportRow> students
) {

	public record StudentImportRow(
			@NotBlank(message = "Số điện thoại học sinh không được trống")
			@Size(max = 20, message = "Số điện thoại tối đa 20 ký tự")
			String phoneNumber,

			@NotBlank(message = "Họ tên học sinh không được trống")
			@Size(max = 120, message = "Họ tên tối đa 120 ký tự")
			String fullName,

			@NotBlank(message = "Mã học sinh không được trống")
			@Size(max = 40, message = "Mã học sinh tối đa 40 ký tự")
			String studentCode,

			@Size(max = 40, message = "Năm học tối đa 40 ký tự")
			String academicYearName,

			@Size(max = 40, message = "Lớp tối đa 40 ký tự")
			String className,

			@Size(min = 8, max = 100, message = "Mật khẩu học sinh phải từ 8 đến 100 ký tự")
			String password,

			@Size(max = 40, message = "Trạng thái học sinh tối đa 40 ký tự")
			String status
	) {
	}
}
