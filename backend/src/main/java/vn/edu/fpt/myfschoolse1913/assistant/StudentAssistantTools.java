package vn.edu.fpt.myfschoolse1913.assistant;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Locale;
import java.util.UUID;
import org.springframework.ai.chat.model.ToolContext;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;
import java.util.List;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationService;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationsResponse;
import vn.edu.fpt.myfschoolse1913.document.SchoolDocumentSearchService;
import vn.edu.fpt.myfschoolse1913.notification.StudentNotificationService;
import vn.edu.fpt.myfschoolse1913.notification.StudentNotificationsResponse;
import vn.edu.fpt.myfschoolse1913.student.StudentScheduleResponse;
import vn.edu.fpt.myfschoolse1913.student.StudentScheduleService;
import vn.edu.fpt.myfschoolse1913.student.StudentSemesterGradesResponse;
import vn.edu.fpt.myfschoolse1913.student.StudentSemesterGradesService;

/**
 * Read-only tools the assistant model calls to ground answers in the current
 * student's real data. Every method resolves the student from the userId the
 * controller placed in the ToolContext — the model can never pick whose data
 * it reads. Reuses the exact services behind the student-facing REST API, so
 * the assistant sees the same data as the app screens.
 */
@Component
class StudentAssistantTools {

	static final String USER_ID = "userId";
	static final String SETTINGS = "assistantSettings";

	private final StudentScheduleService scheduleService;
	private final StudentSemesterGradesService gradesService;
	private final StudentNotificationService notificationService;
	private final StudentApplicationService applicationService;
	private final SchoolDocumentSearchService documentSearchService;

	StudentAssistantTools(
			StudentScheduleService scheduleService,
			StudentSemesterGradesService gradesService,
			StudentNotificationService notificationService,
			StudentApplicationService applicationService,
			SchoolDocumentSearchService documentSearchService
	) {
		this.scheduleService = scheduleService;
		this.gradesService = gradesService;
		this.notificationService = notificationService;
		this.applicationService = applicationService;
		this.documentSearchService = documentSearchService;
	}

	@Tool(description = "Lấy thời khóa biểu cả tuần của học sinh: từng ngày gồm các tiết học, "
			+ "môn, giờ bắt đầu/kết thúc, phòng và giáo viên. Dùng cho mọi câu hỏi về lịch học.")
	StudentScheduleResponse getWeeklySchedule(
			@ToolParam(required = false, description = "Một ngày bất kỳ trong tuần cần xem, định dạng yyyy-MM-dd. "
					+ "Bỏ trống để lấy tuần hiện tại.") String date,
			ToolContext toolContext
	) {
		return scheduleService.getSchedule(userId(toolContext), parseDate(date));
	}

	@Tool(description = "Lấy bảng điểm học kỳ hiện tại của học sinh: điểm từng môn "
			+ "(thường xuyên, giữa kỳ, cuối kỳ, trung bình), nhận xét của giáo viên, "
			+ "điểm trung bình chung và xếp loại.")
	StudentSemesterGradesResponse getSemesterGrades(ToolContext toolContext) {
		return gradesService.getSemesterGrades(userId(toolContext));
	}

	@Tool(description = "Lấy danh sách thông báo của trường gửi tới học sinh, mới nhất trước.")
	StudentNotificationsResponse getNotifications(ToolContext toolContext) {
		return notificationService.getNotifications(userId(toolContext));
	}

	@Tool(description = "Lấy danh sách đơn từ (xin nghỉ, xin về sớm...) học sinh đã gửi "
			+ "và trạng thái duyệt của từng đơn.")
	StudentApplicationsResponse getMyApplications(
			@ToolParam(required = false, description = "Lọc theo trạng thái: PENDING, APPROVED hoặc REJECTED. "
					+ "Bỏ trống để lấy tất cả.") String status,
			ToolContext toolContext
	) {
		return applicationService.getApplications(userId(toolContext), parseStatus(status));
	}

	@Tool(description = "Tìm kiếm trong kho tài liệu của trường: nội quy, quy chế, thông tin trường, "
			+ "tài liệu học tập các môn. Dùng cho mọi câu hỏi về quy định của trường hoặc kiến thức "
			+ "môn học. Trả về các đoạn trích kèm tên tài liệu nguồn.")
	List<SchoolDocumentSearchService.DocumentSnippet> searchSchoolDocuments(
			@ToolParam(description = "Câu truy vấn tìm kiếm, ví dụ: 'quy chế thi lại' hoặc "
					+ "'hàm số bậc hai'") String query,
			ToolContext toolContext
	) {
		var settings = toolContext.getContext().get(SETTINGS)
				instanceof AssistantSettingsService.Snapshot snapshot ? snapshot : null;
		return documentSearchService.search(
				query,
				settings == null ? AssistantSettingsService.DEFAULT_TOP_K : settings.topK(),
				settings == null ? null : settings.similarityThreshold());
	}

	private UUID userId(ToolContext toolContext) {
		return (UUID) toolContext.getContext().get(USER_ID);
	}

	private LocalDate parseDate(String date) {
		if (date == null || date.isBlank()) {
			return null;
		}
		try {
			return LocalDate.parse(date.trim());
		} catch (DateTimeParseException exception) {
			throw new IllegalArgumentException("date phải theo định dạng yyyy-MM-dd");
		}
	}

	private StudentApplicationStatus parseStatus(String status) {
		if (status == null || status.isBlank()) {
			return null;
		}
		try {
			return StudentApplicationStatus.valueOf(status.trim().toUpperCase(Locale.ROOT));
		} catch (IllegalArgumentException exception) {
			throw new IllegalArgumentException("status phải là PENDING, APPROVED hoặc REJECTED");
		}
	}
}
