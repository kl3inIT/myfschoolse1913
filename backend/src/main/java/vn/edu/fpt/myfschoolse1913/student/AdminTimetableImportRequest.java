package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

public record AdminTimetableImportRequest(
		@NotBlank(message = "Vui lòng nhập năm học")
		@Size(max = 40, message = "Năm học tối đa 40 ký tự")
		String academicYearName,

		@NotBlank(message = "Vui lòng nhập học kỳ")
		@Size(max = 40, message = "Học kỳ tối đa 40 ký tự")
		String semesterName,

		@Size(max = 40, message = "Lớp mặc định tối đa 40 ký tự")
		String defaultClassName,

		@NotEmpty(message = "Danh sách tiết học không được trống")
		@Size(max = 500, message = "Mỗi lần import tối đa 500 tiết học")
		List<@Valid TimetableImportRow> slots
) {

	public record TimetableImportRow(
			@Size(max = 40, message = "Tên lớp tối đa 40 ký tự")
			String className,

			@NotNull(message = "Thứ trong tuần không được trống")
			@Min(value = 1, message = "Thứ phải từ 1 (thứ hai) đến 7 (chủ nhật)")
			@Max(value = 7, message = "Thứ phải từ 1 (thứ hai) đến 7 (chủ nhật)")
			Integer dayIndex,

			@NotNull(message = "Số tiết không được trống")
			@Min(value = 1, message = "Số tiết phải từ 1 đến 20")
			@Max(value = 20, message = "Số tiết phải từ 1 đến 20")
			Integer lessonNumber,

			@Size(max = 30, message = "Loại tiết tối đa 30 ký tự")
			String slotType,

			@Size(max = 120, message = "Tiêu đề tối đa 120 ký tự")
			String title,

			@Size(max = 40, message = "Mã môn học tối đa 40 ký tự")
			String subjectCode,

			@Size(max = 120, message = "Tên môn học tối đa 120 ký tự")
			String subjectName,

			@Size(max = 80, message = "Tên phòng tối đa 80 ký tự")
			String roomName,

			@Size(max = 120, message = "Tên giáo viên tối đa 120 ký tự")
			String teacherName,

			@NotBlank(message = "Giờ bắt đầu không được trống")
			String startsAt,

			@NotBlank(message = "Giờ kết thúc không được trống")
			String endsAt
	) {
	}
}
