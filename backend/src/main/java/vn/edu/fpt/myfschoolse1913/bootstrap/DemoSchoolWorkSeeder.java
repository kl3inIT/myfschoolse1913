package vn.edu.fpt.myfschoolse1913.bootstrap;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.LocalDate;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import vn.edu.fpt.myfschoolse1913.schoolwork.AssessmentResult;
import vn.edu.fpt.myfschoolse1913.schoolwork.AssessmentResultRepository;
import vn.edu.fpt.myfschoolse1913.schoolwork.AssessmentType;
import vn.edu.fpt.myfschoolse1913.schoolwork.AttendanceRecord;
import vn.edu.fpt.myfschoolse1913.schoolwork.AttendanceRecordRepository;
import vn.edu.fpt.myfschoolse1913.schoolwork.AttendanceStatus;
import vn.edu.fpt.myfschoolse1913.schoolwork.ConductLevel;
import vn.edu.fpt.myfschoolse1913.schoolwork.GuardianRelationship;
import vn.edu.fpt.myfschoolse1913.schoolwork.HomeroomAssignment;
import vn.edu.fpt.myfschoolse1913.schoolwork.HomeroomAssignmentRepository;
import vn.edu.fpt.myfschoolse1913.schoolwork.ParentProfile;
import vn.edu.fpt.myfschoolse1913.schoolwork.ParentProfileRepository;
import vn.edu.fpt.myfschoolse1913.schoolwork.StudentConductSummary;
import vn.edu.fpt.myfschoolse1913.schoolwork.StudentConductSummaryRepository;
import vn.edu.fpt.myfschoolse1913.schoolwork.StudentGuardian;
import vn.edu.fpt.myfschoolse1913.schoolwork.StudentGuardianRepository;
import vn.edu.fpt.myfschoolse1913.schoolwork.TeacherProfile;
import vn.edu.fpt.myfschoolse1913.schoolwork.TeacherProfileRepository;
import vn.edu.fpt.myfschoolse1913.schoolwork.TeachingAssignment;
import vn.edu.fpt.myfschoolse1913.schoolwork.TeachingAssignmentRepository;
import vn.edu.fpt.myfschoolse1913.schoolwork.TeachingAssignmentType;
import vn.edu.fpt.myfschoolse1913.student.AcademicYearRepository;
import vn.edu.fpt.myfschoolse1913.student.ClassTimetableSlotRepository;
import vn.edu.fpt.myfschoolse1913.student.SchoolClassRepository;
import vn.edu.fpt.myfschoolse1913.student.SemesterRepository;
import vn.edu.fpt.myfschoolse1913.student.Student;
import vn.edu.fpt.myfschoolse1913.student.StudentRepository;
import vn.edu.fpt.myfschoolse1913.student.SubjectRepository;
import vn.edu.fpt.myfschoolse1913.user.AppUser;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;

@Configuration
@ConditionalOnProperty(prefix = "app.bootstrap.demo-user", name = "enabled", havingValue = "true")
public class DemoSchoolWorkSeeder {

  @Bean
  @Order(2)
  ApplicationRunner seedTeacherParentWorkflows(
      AppUserRepository userRepository,
      TeacherProfileRepository teacherRepository,
      ParentProfileRepository parentRepository,
      StudentGuardianRepository guardianRepository,
      TeachingAssignmentRepository teachingRepository,
      HomeroomAssignmentRepository homeroomRepository,
      AttendanceRecordRepository attendanceRepository,
      AssessmentResultRepository assessmentRepository,
      StudentConductSummaryRepository conductRepository,
      StudentRepository studentRepository,
      SchoolClassRepository classRepository,
      AcademicYearRepository yearRepository,
      SemesterRepository semesterRepository,
      SubjectRepository subjectRepository,
      ClassTimetableSlotRepository timetableRepository,
      Clock clock) {
    return args -> {
      var year = yearRepository.findByName("2026-2027").orElseThrow();
      var semester = semesterRepository.findByAcademicYearAndName(year, "Học kỳ 1").orElseThrow();
      var class10A1 = classRepository.findByAcademicYearAndName(year, "10A1").orElseThrow();
      var math = subjectRepository.findByCode("MATH").orElseThrow();
      var informatics = subjectRepository.findByCode("INFORMATICS").orElseThrow();
      var teacherLan =
          teacher(
              teacherRepository,
              userRepository.findByPhoneNumber(DemoStudentFixtures.TEACHER_PHONE).orElseThrow(),
              "GV-001");
      var teacherLong =
          teacher(
              teacherRepository,
              userRepository
                  .findByPhoneNumber(DemoStudentFixtures.SECOND_TEACHER_PHONE)
                  .orElseThrow(),
              "GV-002");
      var parentHa =
          parent(
              parentRepository,
              userRepository.findByPhoneNumber(DemoStudentFixtures.PARENT_PHONE).orElseThrow());
      var parentHuy =
          parent(
              parentRepository,
              userRepository
                  .findByPhoneNumber(DemoStudentFixtures.SECOND_PARENT_PHONE)
                  .orElseThrow());

      var mathAssignment = assignment(teachingRepository, teacherLan, class10A1, math, semester);
      var informaticsAssignment =
          assignment(teachingRepository, teacherLong, class10A1, informatics, semester);
      linkTimetable(timetableRepository, mathAssignment, teacherLan.getUser().getFullName());
      linkTimetable(
          timetableRepository, informaticsAssignment, teacherLong.getUser().getFullName());
      var homeroom =
          homeroomRepository
              .findByTeacherAndSchoolClassAndAcademicYear(teacherLan, class10A1, year)
              .orElseGet(
                  () ->
                      homeroomRepository.save(
                          new HomeroomAssignment(
                              teacherLan, class10A1, year, year.getStartsOn(), year.getEndsOn())));

      var student1 = studentRepository.findByStudentCode("FS26-0001").orElseThrow();
      var student2 = studentRepository.findByStudentCode("FS26-0002").orElseThrow();
      var student25 = studentRepository.findByStudentCode("FS26-0025").orElseThrow();
      guardian(guardianRepository, parentHa, student1, GuardianRelationship.MOTHER, true);
      guardian(guardianRepository, parentHa, student25, GuardianRelationship.MOTHER, true);
      guardian(guardianRepository, parentHuy, student2, GuardianRelationship.FATHER, true);

      var roster = studentRepository.findByClassIdWithUser(class10A1.getId());
      for (int index = 0; index < roster.size(); index++) {
        var student = roster.get(index);
        var base = BigDecimal.valueOf(7.0 + (index % 8) * 0.2);
        assessment(
            assessmentRepository,
            mathAssignment,
            student,
            AssessmentType.REGULAR,
            1,
            "Kiểm tra thường xuyên 1",
            base,
            teacherLan.getUser());
        assessment(
            assessmentRepository,
            mathAssignment,
            student,
            AssessmentType.REGULAR,
            2,
            "Kiểm tra thường xuyên 2",
            base.add(BigDecimal.valueOf(0.4)),
            teacherLan.getUser());
        assessment(
            assessmentRepository,
            mathAssignment,
            student,
            AssessmentType.MIDTERM,
            1,
            "Kiểm tra giữa kỳ",
            base.add(BigDecimal.valueOf(0.2)),
            teacherLan.getUser());
        assessment(
            assessmentRepository,
            mathAssignment,
            student,
            AssessmentType.FINAL,
            1,
            "Kiểm tra cuối kỳ",
            base.add(BigDecimal.valueOf(0.5)),
            teacherLan.getUser());
        var status =
            index == 1
                ? AttendanceStatus.LATE
                : index == 2 ? AttendanceStatus.ABSENT_EXCUSED : AttendanceStatus.PRESENT;
        attendance(
            attendanceRepository,
            mathAssignment,
            student,
            LocalDate.now(clock).minusDays(1),
            1,
            status,
            teacherLan.getUser());
        conduct(
            conductRepository,
            homeroom,
            student,
            semester,
            index == 2 ? ConductLevel.FAIR : ConductLevel.GOOD,
            teacherLan.getUser());
      }
    };
  }

  private TeacherProfile teacher(TeacherProfileRepository repository, AppUser user, String code) {
    return repository
        .findByUserId(user.getId())
        .orElseGet(() -> repository.save(new TeacherProfile(user, code)));
  }

  private ParentProfile parent(ParentProfileRepository repository, AppUser user) {
    return repository
        .findByUserId(user.getId())
        .orElseGet(() -> repository.save(new ParentProfile(user)));
  }

  private TeachingAssignment assignment(
      TeachingAssignmentRepository repository,
      TeacherProfile teacher,
      vn.edu.fpt.myfschoolse1913.student.SchoolClass schoolClass,
      vn.edu.fpt.myfschoolse1913.student.Subject subject,
      vn.edu.fpt.myfschoolse1913.student.Semester semester) {
    return repository
        .findByTeacherAndSchoolClassAndSubjectAndSemesterAndType(
            teacher, schoolClass, subject, semester, TeachingAssignmentType.PRIMARY)
        .orElseGet(
            () ->
                repository.save(
                    new TeachingAssignment(
                        teacher,
                        schoolClass,
                        subject,
                        semester,
                        TeachingAssignmentType.PRIMARY,
                        null,
                        null)));
  }

  private void guardian(
      StudentGuardianRepository repository,
      ParentProfile parent,
      Student student,
      GuardianRelationship relationship,
      boolean primary) {
    var link =
        repository
            .findByParentAndStudent(parent, student)
            .orElseGet(() -> new StudentGuardian(parent, student, relationship, primary));
    link.update(relationship, primary, true);
    repository.save(link);
  }

  private void assessment(
      AssessmentResultRepository repository,
      TeachingAssignment assignment,
      Student student,
      AssessmentType type,
      int sequence,
      String title,
      BigDecimal score,
      AppUser teacher) {
    var result =
        repository
            .findByTeachingAssignmentAndStudentAndTypeAndSequenceNumber(
                assignment, student, type, sequence)
            .orElseGet(
                () ->
                    new AssessmentResult(
                        assignment,
                        student,
                        type,
                        sequence,
                        title,
                        score,
                        "Dữ liệu demo đã công bố",
                        true,
                        teacher));
    result.update(title, score.min(BigDecimal.TEN), "Dữ liệu demo đã công bố", true, teacher);
    repository.save(result);
  }

  private void attendance(
      AttendanceRecordRepository repository,
      TeachingAssignment assignment,
      Student student,
      LocalDate date,
      int lesson,
      AttendanceStatus status,
      AppUser teacher) {
    var record =
        repository
            .findByTeachingAssignmentAndStudentAndAttendanceDateAndLessonNumber(
                assignment, student, date, lesson)
            .orElseGet(
                () ->
                    new AttendanceRecord(assignment, student, date, lesson, status, null, teacher));
    record.update(
        status,
        status == AttendanceStatus.ABSENT_EXCUSED ? "Phụ huynh đã xin phép" : null,
        teacher);
    repository.save(record);
  }

  private void conduct(
      StudentConductSummaryRepository repository,
      HomeroomAssignment assignment,
      Student student,
      vn.edu.fpt.myfschoolse1913.student.Semester semester,
      ConductLevel level,
      AppUser teacher) {
    var summary =
        repository
            .findByStudentAndSemester(student, semester)
            .orElseGet(
                () ->
                    new StudentConductSummary(
                        assignment,
                        student,
                        semester,
                        level,
                        "Chấp hành tốt nội quy lớp",
                        true,
                        teacher));
    summary.update(level, "Chấp hành tốt nội quy lớp", true, teacher);
    repository.save(summary);
  }

  private void linkTimetable(
      ClassTimetableSlotRepository repository, TeachingAssignment assignment, String teacherName) {
    for (var slot :
        repository.findBySchoolClassAndSemesterAndSubject(
            assignment.getSchoolClass(), assignment.getSemester(), assignment.getSubject())) {
      slot.linkTeachingAssignment(assignment.getId(), teacherName);
    }
  }
}
