package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.student.AcademicYearRepository;
import vn.edu.fpt.myfschoolse1913.student.ClassTimetableSlotRepository;
import vn.edu.fpt.myfschoolse1913.student.SchoolClassRepository;
import vn.edu.fpt.myfschoolse1913.student.SemesterRepository;
import vn.edu.fpt.myfschoolse1913.student.SemesterSubjectGrade;
import vn.edu.fpt.myfschoolse1913.student.SemesterSubjectGradeRepository;
import vn.edu.fpt.myfschoolse1913.student.StudentRepository;
import vn.edu.fpt.myfschoolse1913.student.SubjectRepository;
import vn.edu.fpt.myfschoolse1913.user.AppUser;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;
import vn.edu.fpt.myfschoolse1913.user.UserRole;

@Service
public class AdminSchoolWorkService {
  private final AppUserRepository userRepository;
  private final TeacherProfileRepository teacherRepository;
  private final ParentProfileRepository parentRepository;
  private final StudentGuardianRepository guardianRepository;
  private final TeachingAssignmentRepository teachingRepository;
  private final HomeroomAssignmentRepository homeroomRepository;
  private final StudentRepository studentRepository;
  private final SchoolClassRepository classRepository;
  private final AcademicYearRepository yearRepository;
  private final SemesterRepository semesterRepository;
  private final SubjectRepository subjectRepository;
  private final ClassTimetableSlotRepository timetableRepository;
  private final AssessmentResultRepository assessmentRepository;
  private final AssessmentCorrectionAuditRepository correctionAuditRepository;
  private final SemesterSubjectGradeRepository aggregateRepository;
  private final PasswordEncoder passwordEncoder;

  public AdminSchoolWorkService(
      AppUserRepository userRepository,
      TeacherProfileRepository teacherRepository,
      ParentProfileRepository parentRepository,
      StudentGuardianRepository guardianRepository,
      TeachingAssignmentRepository teachingRepository,
      HomeroomAssignmentRepository homeroomRepository,
      StudentRepository studentRepository,
      SchoolClassRepository classRepository,
      AcademicYearRepository yearRepository,
      SemesterRepository semesterRepository,
      SubjectRepository subjectRepository,
      ClassTimetableSlotRepository timetableRepository,
      AssessmentResultRepository assessmentRepository,
      AssessmentCorrectionAuditRepository correctionAuditRepository,
      SemesterSubjectGradeRepository aggregateRepository,
      PasswordEncoder passwordEncoder) {
    this.userRepository = userRepository;
    this.teacherRepository = teacherRepository;
    this.parentRepository = parentRepository;
    this.guardianRepository = guardianRepository;
    this.teachingRepository = teachingRepository;
    this.homeroomRepository = homeroomRepository;
    this.studentRepository = studentRepository;
    this.classRepository = classRepository;
    this.yearRepository = yearRepository;
    this.semesterRepository = semesterRepository;
    this.subjectRepository = subjectRepository;
    this.timetableRepository = timetableRepository;
    this.assessmentRepository = assessmentRepository;
    this.correctionAuditRepository = correctionAuditRepository;
    this.aggregateRepository = aggregateRepository;
    this.passwordEncoder = passwordEncoder;
  }

  @Transactional(readOnly = true)
  public AdminSchoolWorkResponse overview() {
    var teachers = teacherRepository.findAllWithUser().stream().map(this::teacherItem).toList();
    var parents =
        userRepository.findByRoleOrderByFullName(UserRole.PARENT).stream()
            .map(
                user ->
                    parentRepository
                        .findByUserId(user.getId())
                        .map(
                            parent ->
                                new AdminSchoolWorkResponse.ParentItem(
                                    parent.getId(),
                                    user.getId(),
                                    user.getFullName(),
                                    user.getPhoneNumber(),
                                    parent.getStatus()))
                        .orElse(null))
            .filter(java.util.Objects::nonNull)
            .toList();
    var students =
        studentRepository.findAll().stream()
            .sorted(
                java.util.Comparator.comparing(
                    vn.edu.fpt.myfschoolse1913.student.Student::getStudentCode))
            .map(
                student ->
                    new AdminSchoolWorkResponse.StudentItem(
                        student.getId(),
                        student.getStudentCode(),
                        student.getUser().getFullName(),
                        student.getSchoolClass().getId(),
                        student.getSchoolClass().getName()))
            .toList();
    var classes =
        classRepository.findAllByOrderByName().stream()
            .map(
                schoolClass ->
                    new AdminSchoolWorkResponse.ClassItem(
                        schoolClass.getId(),
                        schoolClass.getName(),
                        schoolClass.getAcademicYear().getId(),
                        schoolClass.getAcademicYear().getName()))
            .toList();
    var semesters =
        semesterRepository.findAll().stream()
            .map(
                semester ->
                    new AdminSchoolWorkResponse.SemesterItem(
                        semester.getId(), semester.getName(), semester.getAcademicYear().getId()))
            .toList();
    var subjects =
        subjectRepository.findAll().stream()
            .sorted(
                java.util.Comparator.comparingInt(
                    vn.edu.fpt.myfschoolse1913.student.Subject::getDisplayOrder))
            .map(
                subject ->
                    new AdminSchoolWorkResponse.SubjectItem(
                        subject.getId(), subject.getCode(), subject.getName()))
            .toList();
    return new AdminSchoolWorkResponse(
        teachers,
        parents,
        students,
        classes,
        semesters,
        subjects,
        teachingRepository.findAllWithDetails().stream().map(this::teachingItem).toList(),
        homeroomRepository.findAllWithDetails().stream().map(this::homeroomItem).toList(),
        guardianRepository.findAllWithDetails().stream().map(this::guardianItem).toList(),
        assessmentRepository.findAllPublishedWithDetails().stream()
            .map(this::assessmentItem)
            .toList());
  }

  @Transactional
  public AdminSchoolWorkResponse.TeacherItem createTeacher(CreateTeacherRequest request) {
    if (userRepository.findByPhoneNumber(request.phoneNumber().trim()).isPresent())
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Số điện thoại đã tồn tại");
    if (teacherRepository.findByEmployeeCode(request.employeeCode().trim()).isPresent())
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Mã giáo viên đã tồn tại");
    var user =
        userRepository.save(
            new AppUser(
                request.phoneNumber().trim(),
                passwordEncoder.encode(request.initialPassword()),
                request.fullName().trim(),
                UserRole.TEACHER));
    return teacherItem(
        teacherRepository.save(new TeacherProfile(user, request.employeeCode().trim())));
  }

  @Transactional
  public AdminSchoolWorkResponse.ParentItem createParent(CreateParentRequest request) {
    if (userRepository.findByPhoneNumber(request.phoneNumber().trim()).isPresent())
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Số điện thoại đã tồn tại");
    var user =
        userRepository.save(
            new AppUser(
                request.phoneNumber().trim(),
                passwordEncoder.encode(request.initialPassword()),
                request.fullName().trim(),
                UserRole.PARENT));
    var parent = parentRepository.save(new ParentProfile(user));
    return new AdminSchoolWorkResponse.ParentItem(
        parent.getId(),
        user.getId(),
        user.getFullName(),
        user.getPhoneNumber(),
        parent.getStatus());
  }

  @Transactional
  public AdminSchoolWorkResponse.TeachingAssignmentItem assignTeacher(
      TeachingAssignmentRequest request) {
    validateDates(request.startsOn(), request.endsOn());
    var teacher = requireTeacher(request.teacherId());
    var schoolClass =
        classRepository
            .findById(request.classId())
            .orElseThrow(() -> notFound("Không tìm thấy lớp"));
    var subject =
        subjectRepository
            .findById(request.subjectId())
            .orElseThrow(() -> notFound("Không tìm thấy môn học"));
    var semester =
        semesterRepository
            .findById(request.semesterId())
            .orElseThrow(() -> notFound("Không tìm thấy học kỳ"));
    if (!schoolClass.getAcademicYear().getId().equals(semester.getAcademicYear().getId()))
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Lớp và học kỳ phải cùng năm học");
    var assignment =
        teachingRepository
            .findByTeacherAndSchoolClassAndSubjectAndSemesterAndType(
                teacher, schoolClass, subject, semester, request.type())
            .orElseGet(
                () ->
                    new TeachingAssignment(
                        teacher,
                        schoolClass,
                        subject,
                        semester,
                        request.type(),
                        request.startsOn(),
                        request.endsOn()));
    assignment.update(request.type(), request.startsOn(), request.endsOn(), request.active());
    var savedAssignment = teachingRepository.save(assignment);
    for (var slot :
        timetableRepository.findBySchoolClassAndSemesterAndSubject(
            schoolClass, semester, subject)) {
      slot.linkTeachingAssignment(savedAssignment.getId(), teacher.getUser().getFullName());
    }
    return teachingItem(savedAssignment);
  }

  @Transactional
  public AdminSchoolWorkResponse.HomeroomAssignmentItem assignHomeroom(
      HomeroomAssignmentRequest request) {
    validateDates(request.startsOn(), request.endsOn());
    var teacher = requireTeacher(request.teacherId());
    var schoolClass =
        classRepository
            .findById(request.classId())
            .orElseThrow(() -> notFound("Không tìm thấy lớp"));
    var year =
        yearRepository
            .findById(request.academicYearId())
            .orElseThrow(() -> notFound("Không tìm thấy năm học"));
    if (!schoolClass.getAcademicYear().getId().equals(year.getId()))
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Lớp không thuộc năm học đã chọn");
    homeroomRepository
        .findBySchoolClassAndAcademicYearAndActiveTrue(schoolClass, year)
        .filter(existing -> !existing.getTeacher().getId().equals(teacher.getId()))
        .ifPresent(
            existing -> {
              throw new ResponseStatusException(
                  HttpStatus.CONFLICT, "Lớp đã có giáo viên chủ nhiệm");
            });
    var assignment =
        homeroomRepository
            .findByTeacherAndSchoolClassAndAcademicYear(teacher, schoolClass, year)
            .orElseGet(
                () ->
                    new HomeroomAssignment(
                        teacher, schoolClass, year, request.startsOn(), request.endsOn()));
    assignment.update(request.startsOn(), request.endsOn(), request.active());
    return homeroomItem(homeroomRepository.save(assignment));
  }

  @Transactional
  public AdminSchoolWorkResponse.GuardianLinkItem linkGuardian(GuardianLinkRequest request) {
    var parent =
        parentRepository
            .findById(request.parentId())
            .orElseThrow(() -> notFound("Không tìm thấy phụ huynh"));
    var student =
        studentRepository
            .findById(request.studentId())
            .orElseThrow(() -> notFound("Không tìm thấy học sinh"));
    var link =
        guardianRepository
            .findByParentAndStudent(parent, student)
            .orElseGet(
                () ->
                    new StudentGuardian(
                        parent, student, request.relationship(), request.primaryContact()));
    link.update(request.relationship(), request.primaryContact(), request.active());
    return guardianItem(guardianRepository.save(link));
  }

  @Transactional
  public AdminSchoolWorkResponse.AssessmentItem correctPublishedAssessment(
      UUID adminUserId, UUID resultId, AdminAssessmentCorrectionRequest request) {
    var admin =
        userRepository
            .findById(adminUserId)
            .filter(user -> user.isEnabled() && user.getRole() == UserRole.ADMIN)
            .orElseThrow(() -> notFound("Không tìm thấy quản trị viên"));
    var result =
        assessmentRepository
            .findById(resultId)
            .orElseThrow(() -> notFound("Không tìm thấy kết quả đánh giá"));
    if (!result.isPublished()) {
      throw new ResponseStatusException(
          HttpStatus.CONFLICT, "Chỉ sửa điểm đã công bố qua quy trình hiệu chỉnh");
    }

    var comment = normalizeNullable(request.comment());
    correctionAuditRepository.save(
        new AssessmentCorrectionAudit(
            result,
            result.getScore(),
            request.score(),
            result.getComment(),
            comment,
            request.reason().trim(),
            admin));
    result.update(result.getTitle(), request.score(), comment, true, admin);
    assessmentRepository.save(result);
    refreshAggregate(result);
    return assessmentItem(result);
  }

  private TeacherProfile requireTeacher(UUID id) {
    return teacherRepository.findById(id).orElseThrow(() -> notFound("Không tìm thấy giáo viên"));
  }

  private void validateDates(java.time.LocalDate start, java.time.LocalDate end) {
    if (start != null && end != null && end.isBefore(start))
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Ngày kết thúc phải sau ngày bắt đầu");
  }

  private ResponseStatusException notFound(String message) {
    return new ResponseStatusException(HttpStatus.NOT_FOUND, message);
  }

  private AdminSchoolWorkResponse.TeacherItem teacherItem(TeacherProfile teacher) {
    return new AdminSchoolWorkResponse.TeacherItem(
        teacher.getId(),
        teacher.getUser().getId(),
        teacher.getEmployeeCode(),
        teacher.getUser().getFullName(),
        teacher.getUser().getPhoneNumber(),
        teacher.getStatus());
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

  private AdminSchoolWorkResponse.GuardianLinkItem guardianItem(StudentGuardian link) {
    return new AdminSchoolWorkResponse.GuardianLinkItem(
        link.getId(),
        link.getParent().getId(),
        link.getParent().getUser().getFullName(),
        link.getStudent().getId(),
        link.getStudent().getUser().getFullName(),
        link.getStudent().getSchoolClass().getName(),
        link.getRelationship(),
        link.isPrimaryContact(),
        link.isActive());
  }

  private AdminSchoolWorkResponse.AssessmentItem assessmentItem(AssessmentResult result) {
    return new AdminSchoolWorkResponse.AssessmentItem(
        result.getId(),
        result.getStudent().getStudentCode(),
        result.getStudent().getUser().getFullName(),
        result.getStudent().getSchoolClass().getName(),
        result.getTeachingAssignment().getSubject().getName(),
        result.getTeachingAssignment().getSemester().getName(),
        result.getType(),
        result.getSequenceNumber(),
        result.getTitle(),
        result.getScore(),
        result.getComment());
  }

  private void refreshAggregate(AssessmentResult correctedResult) {
    var assignment = correctedResult.getTeachingAssignment();
    var student = correctedResult.getStudent();
    var results =
        assessmentRepository
            .findByTeachingAssignmentOrderByStudentStudentCodeAscTypeAscSequenceNumberAsc(
                assignment)
            .stream()
            .filter(result -> result.getStudent().getId().equals(student.getId()))
            .toList();
    var regular =
        results.stream()
            .filter(
                result -> result.getType() == AssessmentType.REGULAR && result.getScore() != null)
            .map(AssessmentResult::getScore)
            .toList();
    var midterm = score(results, AssessmentType.MIDTERM);
    var finalScore = score(results, AssessmentType.FINAL);
    var average = VietnameseGradeCalculator.semesterAverage(regular, midterm, finalScore);
    if (average == null) return;

    var formative = VietnameseGradeCalculator.regularAverage(regular);
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

  private java.math.BigDecimal score(
      java.util.List<AssessmentResult> results, AssessmentType type) {
    return results.stream()
        .filter(result -> result.getType() == type && result.getScore() != null)
        .map(AssessmentResult::getScore)
        .findFirst()
        .orElse(null);
  }

  private String normalizeNullable(String value) {
    if (value == null || value.isBlank()) return null;
    return value.trim();
  }
}
