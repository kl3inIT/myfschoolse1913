package vn.edu.fpt.myfschoolse1913.student;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;

public record AdminGradeImportRequest(
		@NotBlank(message = "Vui lòng nhập năm học")
		@Size(max = 40, message = "Năm học tối đa 40 ký tự")
		String academicYearName,

		@NotBlank(message = "Vui lòng nhập học kỳ")
		@Size(max = 40, message = "Học kỳ tối đa 40 ký tự")
		String semesterName,

		@NotEmpty(message = "Danh sách điểm không được trống")
		@Size(max = 500, message = "Mỗi lần import tối đa 500 dòng điểm")
		List<@Valid GradeImportRow> grades
) {

	public record GradeImportRow(
			@NotBlank(message = "Mã học sinh không được trống")
			@Size(max = 40, message = "Mã học sinh tối đa 40 ký tự")
			String studentCode,

			@NotBlank(message = "Mã môn học không được trống")
			@Size(max = 40, message = "Mã môn học tối đa 40 ký tự")
			String subjectCode,

			@Size(max = 120, message = "Tên môn học tối đa 120 ký tự")
			String subjectName,

			@DecimalMin(value = "0", message = "Điểm thường xuyên phải từ 0 đến 10")
			@DecimalMax(value = "10", message = "Điểm thường xuyên phải từ 0 đến 10")
			BigDecimal formativeScore,

			@DecimalMin(value = "0", message = "Điểm giữa kỳ phải từ 0 đến 10")
			@DecimalMax(value = "10", message = "Điểm giữa kỳ phải từ 0 đến 10")
			BigDecimal midtermScore,

			@DecimalMin(value = "0", message = "Điểm cuối kỳ phải từ 0 đến 10")
			@DecimalMax(value = "10", message = "Điểm cuối kỳ phải từ 0 đến 10")
			BigDecimal finalScore,

			@DecimalMin(value = "0", message = "Điểm trung bình phải từ 0 đến 10")
			@DecimalMax(value = "10", message = "Điểm trung bình phải từ 0 đến 10")
			BigDecimal averageScore,

			@Size(max = 255, message = "Nhận xét tối đa 255 ký tự")
			String teacherComment
	) {
	}
}
