package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.application.StudentApplication;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationRepository;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationStatus;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationType;
import vn.edu.fpt.myfschoolse1913.student.SemesterRepository;
import vn.edu.fpt.myfschoolse1913.student.SemesterSubjectGrade;
import vn.edu.fpt.myfschoolse1913.student.SemesterSubjectGradeRepository;
import vn.edu.fpt.myfschoolse1913.student.Student;
import vn.edu.fpt.myfschoolse1913.student.StudentRepository;
import vn.edu.fpt.myfschoolse1913.user.AppUser;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;

@Service
public class TeacherSchoolWorkService {
  private final TeacherProfileRepository teacherRepository;
  private final TeachingAssignmentRepository teachingRepository;
  private final HomeroomAssignmentRepository homeroomRepository;
  private final StudentRepository studentRepository;
  private final AttendanceRecordRepository attendanceRepository;
  private final AssessmentResultRepository assessmentRepository;
  private final SemesterSubjectGradeRepository aggregateRepository;
  private final SemesterRepository semesterRepository;
  private final StudentConductSummaryRepository conductRepository;
  private final StudentApplicationRepository applicationRepository;
  private final AppUserRepository userRepository;

  public TeacherSchoolWorkService(
      TeacherProfileRepository teacherRepository,
      TeachingAssignmentRepository teachingRepository,
      HomeroomAssignmentRepository homeroomRepository,
      StudentRepository studentRepository,
      AttendanceRecordRepository attendanceRepository,
      AssessmentResultRepository assessmentRepository,
      SemesterSubjectGradeRepository aggregateRepository,
      SemesterRepository semesterRepository,
      StudentConductSummaryRepository conductRepository,
      StudentApplicationRepository applicationRepository,
      AppUserRepository userRepository) {
    this.teacherRepository = teacherRepository;
    this.teachingRepository = teachingRepository;
    this.homeroomRepository = homeroomRepository;
    this.studentRepository = studentRepository;
    this.attendanceRepository = attendanceRepository;
    this.assessmentRepository = assessmentRepository;
    this.aggregateRepository = aggregateRepository;
    this.semesterRepository = semesterRepository;
    this.conductRepository = conductRepository;
    this.applicationRepository = applicationRepository;
    this.userRepository = userRepository;
  }

  @Transactional(readOnly = true)
  public TeacherWorkspaceResponse workspace(UUID userId) {
    var teacher = requireTeacher(userId);
    return new TeacherWorkspaceResponse(
        teacher.getId(),
        teacher.getEmployeeCode(),
        teacher.getUser().getFullName(),
        teachingRepository.findActiveByTeacher(teacher).stream().map(this::teachingItem).toList(),
        homeroomRepository.findActiveByTeacher(teacher).stream().map(this::homeroomItem).toList());
  }

  @Transactional(readOnly = true)
  public TeacherClassroomResponse classroom(
      UUID userId, UUID assignmentId, LocalDate date, int lessonNumber) {
    var assignment = requireAssignment(userId, assignmentId, date);
    var attendance =
        attendanceRepository
            .findByTeachingAssignmentAndAttendanceDateAndLessonNumberOrderByStudentStudentCode(
                assignment, date, lessonNumber)
            .stream()
            .collect(Collectors.toMap(record -> record.getStudent().getId(), Function.identity()));
    var assessments =
        assessmentRepository
            .findByTeachingAssignmentOrderByStudentStudentCodeAscTypeAscSequenceNumberAsc(
                assignment)
            .stream()
            .collect(Collectors.groupingBy(result -> result.getStudent().getId()));
    var rows =
        studentRepository.findByClassIdWithUser(assignment.getSchoolClass().getId()).stream()
            .map(
                student ->
                    studentRow(
                        student,
                        attendance.get(student.getId()),
                        assessments.getOrDefault(student.getId(), List.of())))
            .toList();
    return new TeacherClassroomResponse(
        assignment.getId(),
        assignment.getSchoolClass().getName(),
        assignment.getSubject().getName(),
        assignment.getSemester().getName(),
        date,
        lessonNumber,
        rows);
  }

  @Transactional
  public TeacherClassroomResponse saveAttendance(
      UUID userId, UUID assignmentId, AttendanceBatchRequest request) {
    var assignment = requireAssignment(userId, assignmentId, request.date());
    var teacherUser = requireUser(userId);
    var roster =
        studentRepository.findByClassIdWithUser(assignment.getSchoolClass().getId()).stream()
            .collect(Collectors.toMap(Student::getId, Function.identity()));
    for (var entry : request.entries()) {
      var student = roster.get(entry.studentId());
      if (student == null)
        throw new ResponseStatusException(
            HttpStatus.FORBIDDEN, "Học sinh không thuộc lớp được phân công");
      var record =
          attendanceRepository
              .findByTeachingAssignmentAndStudentAndAttendanceDateAndLessonNumber(
                  assignment, student, request.date(), request.lessonNumber())
              .orElseGet(
                  () ->
                      new AttendanceRecord(
                          assignment,
                          student,
                          request.date(),
                          request.lessonNumber(),
                          entry.status(),
                          entry.note(),
                          teacherUser));
      record.update(entry.status(), clean(entry.note()), teacherUser);
      attendanceRepository.save(record);
    }
    return classroom(userId, assignmentId, request.date(), request.lessonNumber());
  }

  @Transactional
  public TeacherClassroomResponse saveGrades(
      UUID userId, UUID assignmentId, GradeBatchRequest request) {
    if (request.type() != AssessmentType.REGULAR && request.sequenceNumber() != 1)
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Giữa kỳ và cuối kỳ chỉ có một đầu điểm");
    var assignment = requireAssignment(userId, assignmentId, LocalDate.now());
    var teacherUser = requireUser(userId);
    var roster =
        studentRepository.findByClassIdWithUser(assignment.getSchoolClass().getId()).stream()
            .collect(Collectors.toMap(Student::getId, Function.identity()));
    for (var entry : request.entries()) {
      var student = roster.get(entry.studentId());
      if (student == null)
        throw new ResponseStatusException(
            HttpStatus.FORBIDDEN, "Học sinh không thuộc lớp được phân công");
      var result =
          assessmentRepository
              .findByTeachingAssignmentAndStudentAndTypeAndSequenceNumber(
                  assignment, student, request.type(), request.sequenceNumber())
              .orElse(null);
      var requestedTitle = request.title().trim();
      var requestedComment = clean(entry.comment());
      if (result != null
          && result.isPublished()
          && (changed(result.getScore(), entry.score())
              || !result.getTitle().equals(requestedTitle)
              || !java.util.Objects.equals(result.getComment(), requestedComment)
              || !request.published()))
        throw new ResponseStatusException(
            HttpStatus.CONFLICT, "Điểm đã công bố; cần quy trình hiệu chỉnh của quản trị viên");
      if (request.published() && entry.score() == null)
        throw new ResponseStatusException(
            HttpStatus.BAD_REQUEST, "Không thể công bố đầu điểm chưa có điểm số");
      if (result == null)
        result =
            new AssessmentResult(
                assignment,
                student,
                request.type(),
                request.sequenceNumber(),
                requestedTitle,
                entry.score(),
                requestedComment,
                request.published(),
                teacherUser);
      else
        result.update(
            requestedTitle, entry.score(), requestedComment, request.published(), teacherUser);
      assessmentRepository.save(result);
      refreshAggregate(assignment, student);
    }
    return classroom(userId, assignmentId, LocalDate.now(), 1);
  }

  @Transactional(readOnly = true)
  public TeacherApplicationsResponse homeroomApplications(UUID userId, UUID classId) {
    var homeroom = requireHomeroom(userId, classId);
    return new TeacherApplicationsResponse(
        homeroom.getSchoolClass().getName(),
        applicationRepository.findByClassIdForHomeroom(classId).stream()
            .map(this::applicationItem)
            .toList());
  }

  @Transactional
  public TeacherApplicationsResponse.Item reviewApplication(
      UUID userId, UUID classId, UUID applicationId, TeacherApplicationReviewRequest request) {
    requireHomeroom(userId, classId);
    if (request.status() != StudentApplicationStatus.APPROVED
        && request.status() != StudentApplicationStatus.REJECTED)
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Trạng thái duyệt không hợp lệ");
    var application =
        applicationRepository
            .findById(applicationId)
            .orElseThrow(
                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn"));
    if (application.getStatus() != StudentApplicationStatus.PENDING)
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Đơn đã được xử lý trước đó");
    if (!application.getStudent().getSchoolClass().getId().equals(classId))
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Đơn không thuộc lớp chủ nhiệm");
    if (application.getType() == StudentApplicationType.DOCUMENT_REQUEST)
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN, "Đơn xin giấy tờ do quản trị viên xử lý");
    if (ChronoUnit.DAYS.between(application.getTargetDate(), application.getEndDate()) + 1 > 3)
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN, "Giáo viên chủ nhiệm chỉ duyệt nghỉ tối đa 3 ngày liên tiếp");
    var reviewer = requireUser(userId);
    if (request.status() == StudentApplicationStatus.APPROVED)
      application.approve(request.reviewerNote().trim(), Instant.now(), reviewer);
    else application.reject(request.reviewerNote().trim(), Instant.now(), reviewer);
    return applicationItem(applicationRepository.save(application));
  }

  @Transactional
  public void saveConduct(UUID userId, UUID classId, ConductBatchRequest request) {
    var homeroom = requireHomeroom(userId, classId);
    var semester =
        semesterRepository
            .findById(request.semesterId())
            .orElseThrow(
                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy học kỳ"));
    if (!semester.getAcademicYear().getId().equals(homeroom.getAcademicYear().getId()))
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Học kỳ không thuộc năm học chủ nhiệm");
    var user = requireUser(userId);
    var roster =
        studentRepository.findByClassIdWithUser(classId).stream()
            .collect(Collectors.toMap(Student::getId, Function.identity()));
    for (var entry : request.entries()) {
      var student = roster.get(entry.studentId());
      if (student == null)
        throw new ResponseStatusException(
            HttpStatus.FORBIDDEN, "Học sinh không thuộc lớp chủ nhiệm");
      var summary =
          conductRepository
              .findByStudentAndSemester(student, semester)
              .orElseGet(
                  () ->
                      new StudentConductSummary(
                          homeroom,
                          student,
                          semester,
                          entry.level(),
                          clean(entry.comment()),
                          request.published(),
                          user));
      summary.update(entry.level(), clean(entry.comment()), request.published(), user);
      conductRepository.save(summary);
    }
  }

  private TeacherProfile requireTeacher(UUID userId) {
    return teacherRepository
        .findActiveByUserId(userId)
        .orElseThrow(
            () ->
                new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED, "Phiên giáo viên không hợp lệ"));
  }

  private AppUser requireUser(UUID userId) {
    return userRepository
        .findById(userId)
        .orElseThrow(
            () ->
                new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED, "Phiên đăng nhập không hợp lệ"));
  }

  private TeachingAssignment requireAssignment(UUID userId, UUID assignmentId, LocalDate date) {
    var assignment =
        teachingRepository
            .findActiveOwned(assignmentId, requireTeacher(userId))
            .orElseThrow(
                () ->
                    new ResponseStatusException(
                        HttpStatus.FORBIDDEN, "Không có phân công cho lớp và môn học này"));
    if (!assignment.isEffectiveOn(date))
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN, "Phân công chưa có hiệu lực hoặc đã hết hạn");
    return assignment;
  }

  private HomeroomAssignment requireHomeroom(UUID userId, UUID classId) {
    return homeroomRepository
        .findActiveOwnedClass(requireTeacher(userId), classId)
        .orElseThrow(
            () ->
                new ResponseStatusException(
                    HttpStatus.FORBIDDEN, "Không phải giáo viên chủ nhiệm của lớp này"));
  }

  private String clean(String value) {
    return value == null || value.isBlank() ? null : value.trim();
  }

  private boolean changed(BigDecimal current, BigDecimal next) {
    return current == null ? next != null : next == null || current.compareTo(next) != 0;
  }

  private TeacherClassroomResponse.StudentRow studentRow(
      Student student, AttendanceRecord attendance, List<AssessmentResult> results) {
    return new TeacherClassroomResponse.StudentRow(
        student.getId(),
        student.getStudentCode(),
        student.getUser().getFullName(),
        attendance == null ? null : attendance.getStatus(),
        attendance == null ? null : attendance.getNote(),
        results.stream().map(this::assessmentItem).toList(),
        calculateAverage(results));
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

  private void refreshAggregate(TeachingAssignment assignment, Student student) {
    var results =
        assessmentRepository
            .findByTeachingAssignmentOrderByStudentStudentCodeAscTypeAscSequenceNumberAsc(
                assignment)
            .stream()
            .filter(result -> result.getStudent().getId().equals(student.getId()))
            .toList();
    var average = calculateAverage(results);
    if (average == null) return;
    var regular =
        results.stream()
            .filter(
                result -> result.getType() == AssessmentType.REGULAR && result.getScore() != null)
            .map(AssessmentResult::getScore)
            .toList();
    var formative = VietnameseGradeCalculator.regularAverage(regular);
    var midterm = score(results, AssessmentType.MIDTERM);
    var finalScore = score(results, AssessmentType.FINAL);
    var detail = "TX %s · GK %s · CK %s".formatted(regular, midterm, finalScore);
    var comment =
        results.stream()
            .map(AssessmentResult::getComment)
            .filter(java.util.Objects::nonNull)
            .reduce((first, second) -> second)
            .orElse(null);
    var aggregate =
        aggregateRepository
            .findByStudentAndSemesterAndSubject(
                student, assignment.getSemester(), assignment.getSubject())
            .orElseGet(
                () ->
                    new SemesterSubjectGrade(
                        student,
                        assignment.getSemester(),
                        assignment.getSubject(),
                        formative,
                        midterm,
                        finalScore,
                        average,
                        detail,
                        comment));
    aggregate.updateScores(formative, midterm, finalScore, average, detail, comment);
    aggregateRepository.save(aggregate);
  }

  private TeacherClassroomResponse.AssessmentItem assessmentItem(AssessmentResult result) {
    return new TeacherClassroomResponse.AssessmentItem(
        result.getId(),
        result.getType(),
        result.getSequenceNumber(),
        result.getTitle(),
        result.getScore(),
        result.getComment(),
        result.isPublished());
  }

  private AdminSchoolWorkResponse.TeachingAssignmentItem teachingItem(
      TeachingAssignment assignment) {
    return new AdminSchoolWorkResponse.TeachingAssignmentItem(
        assignment.getId(),
        assignment.getTeacher().getId(),
        assignment.getTeacher().getUser().getFullName(),
        assignment.getSchoolClass().getId(),
        assignment.getSchoolClass().getName(),
        assignment.getSubject().getId(),
        assignment.getSubject().getName(),
        assignment.getSemester().getId(),
        assignment.getSemester().getName(),
        assignment.getType(),
        assignment.getStartsOn(),
        assignment.getEndsOn(),
        assignment.isActive());
  }

  private AdminSchoolWorkResponse.HomeroomAssignmentItem homeroomItem(
      HomeroomAssignment assignment) {
    return new AdminSchoolWorkResponse.HomeroomAssignmentItem(
        assignment.getId(),
        assignment.getTeacher().getId(),
        assignment.getTeacher().getUser().getFullName(),
        assignment.getSchoolClass().getId(),
        assignment.getSchoolClass().getName(),
        assignment.getAcademicYear().getId(),
        assignment.getAcademicYear().getName(),
        assignment.isActive());
  }

  private TeacherApplicationsResponse.Item applicationItem(StudentApplication application) {
    return new TeacherApplicationsResponse.Item(
        application.getId(),
        application.getStudent().getId(),
        application.getStudent().getStudentCode(),
        application.getStudent().getUser().getFullName(),
        application.getType(),
        application.getStatus(),
        application.getTargetDate(),
        application.getEndDate(),
        application.getRequestedTime(),
        application.getReason(),
        application.getDetails(),
        application.getReviewerNote(),
        application.getCreatedAt());
  }
}
