package vn.edu.fpt.myfschoolse1913.schoolwork;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.myfschoolse1913.application.StudentApplicationRepository;
import vn.edu.fpt.myfschoolse1913.notification.SchoolNotificationRepository;
import vn.edu.fpt.myfschoolse1913.student.ClassTimetableSlotRepository;
import vn.edu.fpt.myfschoolse1913.student.SemesterRepository;
import vn.edu.fpt.myfschoolse1913.student.SemesterSubjectGradeRepository;
import vn.edu.fpt.myfschoolse1913.student.StudentRepository;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;

class RoleScopeServiceTests {
  private TeacherProfileRepository teacherRepository;
  private TeachingAssignmentRepository teachingRepository;
  private StudentGuardianRepository guardianRepository;
  private ParentProfileRepository parentRepository;

  @BeforeEach
  void setUp() {
    teacherRepository = mock(TeacherProfileRepository.class);
    teachingRepository = mock(TeachingAssignmentRepository.class);
    guardianRepository = mock(StudentGuardianRepository.class);
    parentRepository = mock(ParentProfileRepository.class);
  }

  @Test
  void teacherCannotOpenAClassroomWithoutAnActiveOwnedAssignment() {
    var userId = UUID.randomUUID();
    var assignmentId = UUID.randomUUID();
    var teacher = mock(TeacherProfile.class);
    when(teacherRepository.findActiveByUserId(userId)).thenReturn(Optional.of(teacher));
    when(teachingRepository.findActiveOwned(assignmentId, teacher)).thenReturn(Optional.empty());

    var service =
        new TeacherSchoolWorkService(
            teacherRepository,
            teachingRepository,
            mock(HomeroomAssignmentRepository.class),
            mock(StudentRepository.class),
            mock(AttendanceRecordRepository.class),
            mock(AssessmentResultRepository.class),
            mock(SemesterSubjectGradeRepository.class),
            mock(SemesterRepository.class),
            mock(StudentConductSummaryRepository.class),
            mock(StudentApplicationRepository.class),
            mock(AppUserRepository.class));

    assertThatThrownBy(() -> service.classroom(userId, assignmentId, LocalDate.now(), 1))
        .isInstanceOfSatisfying(
            ResponseStatusException.class,
            exception -> assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN));
  }

  @Test
  void parentCannotSelectAStudentWithoutAnActiveGuardianLink() {
    var userId = UUID.randomUUID();
    var selectedStudentId = UUID.randomUUID();
    var parent = mock(ParentProfile.class);
    when(parentRepository.findActiveByUserId(userId)).thenReturn(Optional.of(parent));
    when(guardianRepository.findActiveByParent(parent))
        .thenReturn(List.of(mock(StudentGuardian.class)));
    when(guardianRepository.findActiveLink(parent, selectedStudentId)).thenReturn(Optional.empty());

    var service =
        new ParentSchoolWorkService(
            parentRepository,
            guardianRepository,
            mock(SemesterRepository.class),
            mock(ClassTimetableSlotRepository.class),
            mock(AssessmentResultRepository.class),
            mock(AttendanceRecordRepository.class),
            mock(StudentConductSummaryRepository.class),
            mock(StudentApplicationRepository.class),
            mock(SchoolNotificationRepository.class),
            mock(AppUserRepository.class));

    assertThatThrownBy(() -> service.workspace(userId, selectedStudentId))
        .isInstanceOfSatisfying(
            ResponseStatusException.class,
            exception -> assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND));
  }
}
