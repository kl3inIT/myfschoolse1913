package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttendanceRecordRepository extends JpaRepository<AttendanceRecord, UUID> {
  Optional<AttendanceRecord> findByTeachingAssignmentAndStudentAndAttendanceDateAndLessonNumber(
      TeachingAssignment assignment,
      vn.edu.fpt.myfschoolse1913.student.Student student,
      LocalDate date,
      int lessonNumber);

  List<AttendanceRecord>
      findByTeachingAssignmentAndAttendanceDateAndLessonNumberOrderByStudentStudentCode(
          TeachingAssignment assignment, LocalDate date, int lessonNumber);

  List<AttendanceRecord> findByStudentOrderByAttendanceDateDescLessonNumberDesc(
      vn.edu.fpt.myfschoolse1913.student.Student student);
}
