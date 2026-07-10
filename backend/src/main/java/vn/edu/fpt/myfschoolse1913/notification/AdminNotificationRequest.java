package vn.edu.fpt.myfschoolse1913.notification;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record AdminNotificationRequest(
		@NotBlank(message = "Vui lòng nhập tiêu đề")
		@Size(max = 160, message = "Tiêu đề tối đa 160 ký tự")
		String title,

		@NotBlank(message = "Vui lòng nhập nội dung")
		@Size(max = 1000, message = "Nội dung tối đa 1000 ký tự")
		String body,

		@NotNull(message = "Vui lòng chọn phân loại")
		SchoolNotificationCategory category,

		@NotNull(message = "Vui lòng chọn đối tượng nhận")
		SchoolNotificationAudience audience,

		boolean pinned
) {
}
