package vn.edu.fpt.myfschoolse1913.application;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.myfschoolse1913.student.CurrentStudentService;

@Service
public class StudentApplicationService {

	private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");
	private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

	private final CurrentStudentService currentStudentService;
	private final StudentApplicationRepository applicationRepository;

	public StudentApplicationService(
			CurrentStudentService currentStudentService,
			StudentApplicationRepository applicationRepository
	) {
		this.currentStudentService = currentStudentService;
		this.applicationRepository = applicationRepository;
	}

	@Transactional(readOnly = true)
	public StudentApplicationsResponse getApplications(UUID userId, StudentApplicationStatus status) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var applications = status == null
				? applicationRepository.findByStudentOrderByCreatedAtDesc(student)
				: applicationRepository.findByStudentAndStatusOrderByCreatedAtDesc(student, status);

		return new StudentApplicationsResponse(
				applications.stream()
						.map(this::toItem)
						.toList()
		);
	}

	@Transactional
	public StudentApplicationsResponse.ApplicationItem createApplication(
			UUID userId,
			CreateStudentApplicationRequest request
	) {
		var student = currentStudentService.requireCurrentStudent(userId);
		var application = applicationRepository.save(new StudentApplication(
				student,
				request.type(),
				request.targetDate(),
				request.requestedTime(),
				request.reason().trim(),
				request.details() == null ? null : request.details().trim()
		));

		return toItem(application);
	}

	private StudentApplicationsResponse.ApplicationItem toItem(StudentApplication application) {
		return new StudentApplicationsResponse.ApplicationItem(
				application.getId(),
				application.getType().name(),
				application.getStatus().name(),
				title(application.getType()),
				summary(application),
				application.getTargetDate(),
				application.getRequestedTime(),
				application.getCreatedAt()
		);
	}

	private String title(StudentApplicationType type) {
		return switch (type) {
			case ABSENCE -> "Đơn xin nghỉ học";
			case EARLY_PICKUP -> "Đơn đón về sớm";
			case MEAL_REGISTRATION -> "Đăng ký suất ăn";
		};
	}

	private String summary(StudentApplication application) {
		return switch (application.getType()) {
			case ABSENCE -> "Nghỉ ngày " + application.getTargetDate().format(DATE_FORMATTER);
			case EARLY_PICKUP -> earlyPickupSummary(application);
			case MEAL_REGISTRATION -> mealSummary(application);
		};
	}

	private String earlyPickupSummary(StudentApplication application) {
		var time = application.getRequestedTime() == null
				? ""
				: application.getRequestedTime().format(TIME_FORMATTER) + " ";
		return time + "ngày " + application.getTargetDate().format(DATE_FORMATTER);
	}

	private String mealSummary(StudentApplication application) {
		if (application.getDetails() == null || application.getDetails().isBlank()) {
			return "Cập nhật suất ăn ngày " + application.getTargetDate().format(DATE_FORMATTER);
		}
		return application.getDetails();
	}
}
