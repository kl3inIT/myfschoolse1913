package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.application.StudentApplication;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationRepository;
import vn.edu.fpt.myfschoolse1913.notification.SchoolNotificationRepository;
import vn.edu.fpt.myfschoolse1913.student.ClassTimetableSlotRepository;
import vn.edu.fpt.myfschoolse1913.student.SemesterRepository;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;

@Service
public class ParentSchoolWorkService {
  private final ParentProfileRepository parentRepository;
  private final StudentGuardianRepository guardianRepository;
  private final SemesterRepository semesterRepository;
  private final ClassTimetableSlotRepository timetableRepository;
  private final AssessmentResultRepository assessmentRepository;
  private final AttendanceRecordRepository attendanceRepository;
  private final StudentConductSummaryRepository conductRepository;
  private final StudentApplicationRepository applicationRepository;
  private final SchoolNotificationRepository notificationRepository;
  private final AppUserRepository userRepository;

  public ParentSchoolWorkService(
      ParentProfileRepository parentRepository,
      StudentGuardianRepository guardianRepository,
      SemesterRepository semesterRepository,
      ClassTimetableSlotRepository timetableRepository,
      AssessmentResultRepository assessmentRepository,
      AttendanceRecordRepository attendanceRepository,
      StudentConductSummaryRepository conductRepository,
      StudentApplicationRepository applicationRepository,
      SchoolNotificationRepository notificationRepository,
      AppUserRepository userRepository) {
    this.parentRepository = parentRepository;
    this.guardianRepository = guardianRepository;
    this.semesterRepository = semesterRepository;
    this.timetableRepository = timetableRepository;
    this.assessmentRepository = assessmentRepository;
    this.attendanceRepository = attendanceRepository;
    this.conductRepository = conductRepository;
    this.applicationRepository = applicationRepository;
    this.notificationRepository = notificationRepository;
    this.userRepository = userRepository;
  }

  @Transactional(readOnly = true)
  public ParentWorkspaceResponse workspace(UUID userId, UUID selectedStudentId) {
    var parent = requireParent(userId);
    var links = guardianRepository.findActiveByParent(parent);
    var selectedLink =
        selectedStudentId == null
            ? (links.isEmpty() ? null : links.getFirst())
            : guardianRepository
                .findActiveLink(parent, selectedStudentId)
                .orElseThrow(
                    () ->
                        new ResponseStatusException(
                            HttpStatus.NOT_FOUND, "Không tìm thấy học sinh được liên kết"));
    var children = links.stream().map(this::childItem).toList();
    if (selectedLink == null) return new ParentWorkspaceResponse(children, null);
    return new ParentWorkspaceResponse(children, details(selectedLink));
  }

  @Transactional
  public ParentWorkspaceResponse.ApplicationItem createApplication(
      UUID userId, UUID studentId, CreateParentApplicationRequest request) {
    if (request.type()
        == vn.edu.fpt.myfschoolse1913.application.StudentApplicationType.MEAL_REGISTRATION)
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Dịch vụ bán trú không thuộc luồng đơn từ phụ huynh");
    var parent = requireParent(userId);
    var link =
        guardianRepository
            .findActiveLink(parent, studentId)
            .orElseThrow(
                () ->
                    new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Không tìm thấy học sinh được liên kết"));
    var endDate = request.endDate() == null ? request.startDate() : request.endDate();
    if (endDate.isBefore(request.startDate()))
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Ngày kết thúc phải sau ngày bắt đầu");
    if (request.type() != vn.edu.fpt.myfschoolse1913.application.StudentApplicationType.ABSENCE
        && !endDate.equals(request.startDate()))
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Đơn vào muộn, về sớm hoặc giấy tờ chỉ áp dụng một ngày");
    var creator =
        userRepository
            .findById(userId)
            .orElseThrow(
                () ->
                    new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED, "Phiên phụ huynh không hợp lệ"));
    var application =
        new StudentApplication(
            link.getStudent(),
            request.type(),
            request.startDate(),
            endDate,
            request.requestedTime(),
            request.reason().trim(),
            clean(request.details()),
            creator);
    return applicationItem(applicationRepository.save(application));
  }

  private ParentProfile requireParent(UUID userId) {
    return parentRepository
        .findActiveByUserId(userId)
        .orElseThrow(
            () ->
                new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED, "Phiên phụ huynh không hợp lệ"));
  }

  private ParentWorkspaceResponse.ChildItem childItem(StudentGuardian link) {
    var student = link.getStudent();
    return new ParentWorkspaceResponse.ChildItem(
        student.getId(),
        student.getStudentCode(),
        student.getUser().getFullName(),
        student.getSchoolClass().getName(),
        link.getRelationship(),
        link.isPrimaryContact());
  }

  private ParentWorkspaceResponse.ChildDetails details(StudentGuardian link) {
    var student = link.getStudent();
    var semester =
        semesterRepository
            .findFirstByAcademicYearAndCurrentSemesterTrue(
                student.getSchoolClass().getAcademicYear())
            .orElse(null);
    var schedule =
        semester == null
            ? List.<ParentWorkspaceResponse.ScheduleItem>of()
            : timetableRepository
                .findBySchoolClassAndSemesterOrderByDayIndexAscLessonNumberAsc(
                    student.getSchoolClass(), semester)
                .stream()
                .map(
                    slot ->
                        new ParentWorkspaceResponse.ScheduleItem(
                            slot.getDayIndex(),
                            slot.getLessonNumber(),
                            slot.getTitle(),
                            slot.getSubject() == null ? null : slot.getSubject().getName(),
                            slot.getRoomName(),
                            slot.getTeacherName(),
                            slot.getStartsAt(),
                            slot.getEndsAt()))
                .toList();
    var grades =
        assessmentRepository
            .findByStudentAndPublishedTrueOrderByTeachingAssignmentSubjectDisplayOrderAscTypeAscSequenceNumberAsc(
                student)
            .stream()
            .collect(
                Collectors.groupingBy(
                    result -> result.getTeachingAssignment().getSubject(),
                    java.util.LinkedHashMap::new,
                    Collectors.toList()))
            .entrySet()
            .stream()
            .map(
                entry ->
                    new ParentWorkspaceResponse.SubjectGradeItem(
                        entry.getKey().getId(),
                        entry.getKey().getName(),
                        entry.getValue().stream()
                            .map(
                                result ->
                                    new ParentWorkspaceResponse.AssessmentItem(
                                        result.getType(),
                                        result.getSequenceNumber(),
                                        result.getTitle(),
                                        result.getScore(),
                                        result.getComment()))
                            .toList(),
                        calculateAverage(entry.getValue())))
            .toList();
    var attendance =
        attendanceRepository
            .findByStudentOrderByAttendanceDateDescLessonNumberDesc(student)
            .stream()
            .map(
                record ->
                    new ParentWorkspaceResponse.AttendanceItem(
                        record.getAttendanceDate(),
                        record.getLessonNumber(),
                        record.getTeachingAssignment().getSubject().getName(),
                        record.getStatus(),
                        record.getNote()))
            .toList();
    var conduct =
        conductRepository.findByStudentAndPublishedTrue(student).stream()
            .map(
                summary ->
                    new ParentWorkspaceResponse.ConductItem(
                        summary.getSemester().getName(), summary.getLevel(), summary.getComment()))
            .toList();
    var applications =
        applicationRepository.findByStudentOrderByCreatedAtDesc(student).stream()
            .map(this::applicationItem)
            .toList();
    var notifications =
        notificationRepository.findByActiveTrueOrderByPinnedDescPublishedAtDesc().stream()
            .limit(8)
            .map(
                item ->
                    new ParentWorkspaceResponse.NotificationItem(
                        item.getId(),
                        item.getTitle(),
                        item.getBody(),
                        item.getCategory().name(),
                        item.getPublishedAt(),
                        item.isPinned()))
            .toList();
    return new ParentWorkspaceResponse.ChildDetails(
        childItem(link),
        student.getSchoolClass().getAcademicYear().getName(),
        semester == null ? null : semester.getName(),
        schedule,
        grades,
        attendance,
        conduct,
        applications,
        notifications);
  }

  private BigDecimal calculateAverage(List<AssessmentResult> results) {
    var regular =
        results.stream()
            .filter(
                result -> result.getType() == AssessmentType.REGULAR && result.getScore() != null)
            .map(AssessmentResult::getScore)
            .toList();
    var midterm = score(results, AssessmentType.MIDTERM);
    var finalScore = score(results, AssessmentType.FINAL);
    return VietnameseGradeCalculator.semesterAverage(regular, midterm, finalScore);
  }

  private BigDecimal score(List<AssessmentResult> results, AssessmentType type) {
    return results.stream()
        .filter(result -> result.getType() == type && result.getScore() != null)
        .map(AssessmentResult::getScore)
        .findFirst()
        .orElse(null);
  }

  private ParentWorkspaceResponse.ApplicationItem applicationItem(StudentApplication application) {
    return new ParentWorkspaceResponse.ApplicationItem(
        application.getId(),
        application.getType(),
        application.getStatus(),
        application.getTargetDate(),
        application.getEndDate(),
        application.getRequestedTime(),
        application.getReason(),
        application.getReviewerNote(),
        application.getCreatedAt());
  }

  private String clean(String value) {
    return value == null || value.isBlank() ? null : value.trim();
  }
}
