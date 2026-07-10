package vn.edu.fpt.myfschoolse1913.application;

import java.time.Clock;
import java.time.Instant;
import java.util.Locale;
import java.util.UUID;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.application.AdminApplicationListResponse.Item;

@Service
public class AdminApplicationService {

	private static final int MAX_PAGE_SIZE = 200;

	private final StudentApplicationRepository applicationRepository;
	private final Clock clock;

	public AdminApplicationService(StudentApplicationRepository applicationRepository, Clock clock) {
		this.applicationRepository = applicationRepository;
		this.clock = clock;
	}

	@Transactional(readOnly = true)
	public AdminApplicationListResponse listApplications(
			String search,
			String status,
			int page,
			int size
	) {
		var safePage = Math.max(page, 0);
		var safeSize = Math.min(Math.max(size, 1), MAX_PAGE_SIZE);
		var normalizedSearch = search == null ? "" : search.trim().toLowerCase(Locale.ROOT);
		var statusFilter = resolveStatusFilter(status);
		var pageable = PageRequest.of(safePage, safeSize, Sort.by("createdAt").descending());

		var result = applicationRepository.searchForAdmin(normalizedSearch, statusFilter, pageable);
		var items = result.getContent().stream().map(this::toItem).toList();

		return new AdminApplicationListResponse(
				safePage,
				safeSize,
				result.getTotalElements(),
				result.getTotalPages(),
				items
		);
	}

	@Transactional(readOnly = true)
	public AdminApplicationStatsResponse applicationStats() {
		return applicationRepository.adminStats();
	}

	@Transactional
	public Item reviewApplication(UUID id, AdminApplicationReviewRequest request) {
		var application = applicationRepository.findById(id)
				.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn từ"));

		if (application.getStatus() != StudentApplicationStatus.PENDING) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Đơn từ đã được duyệt trước đó");
		}

		var reviewerNote = request.reviewerNote() == null || request.reviewerNote().isBlank()
				? null
				: request.reviewerNote().trim();
		var reviewedAt = Instant.now(clock);

		switch (request.decision()) {
			case APPROVED -> application.approve(reviewerNote, reviewedAt);
			case REJECTED -> application.reject(reviewerNote, reviewedAt);
			case PENDING -> throw new ResponseStatusException(
					HttpStatus.BAD_REQUEST,
					"Quyết định duyệt phải là APPROVED hoặc REJECTED"
			);
		}

		return toItem(application);
	}

	private StudentApplicationStatus resolveStatusFilter(String status) {
		if (status == null || status.isBlank()) {
			return null;
		}
		try {
			return StudentApplicationStatus.valueOf(status.trim().toUpperCase(Locale.ROOT));
		} catch (IllegalArgumentException exception) {
			throw new ResponseStatusException(
					HttpStatus.BAD_REQUEST,
					"Trạng thái lọc phải là PENDING, APPROVED hoặc REJECTED"
			);
		}
	}

	private Item toItem(StudentApplication application) {
		var student = application.getStudent();
		return new Item(
				application.getId(),
				student.getStudentCode(),
				student.getUser().getFullName(),
				student.getSchoolClass().getName(),
				student.getSchoolClass().getAcademicYear().getName(),
				application.getType().name(),
				application.getStatus().name(),
				application.getTargetDate(),
				application.getRequestedTime(),
				application.getReason(),
				application.getDetails(),
				application.getReviewerNote(),
				application.getCreatedAt(),
				application.getReviewedAt()
		);
	}
}
