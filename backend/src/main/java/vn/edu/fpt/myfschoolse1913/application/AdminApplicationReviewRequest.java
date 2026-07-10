package vn.edu.fpt.myfschoolse1913.application;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record AdminApplicationReviewRequest(
		@NotNull(message = "Vui lòng chọn quyết định duyệt")
		StudentApplicationStatus decision,

		@Size(max = 500, message = "Ghi chú duyệt tối đa 500 ký tự")
		String reviewerNote
) {
}
