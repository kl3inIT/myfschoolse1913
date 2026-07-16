package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AssessmentResultRepository extends JpaRepository<AssessmentResult, UUID> {
  @org.springframework.data.jpa.repository.Query(
      """
      select result from AssessmentResult result
      join fetch result.student student join fetch student.user
      join fetch student.schoolClass
      join fetch result.teachingAssignment assignment join fetch assignment.subject
      where result.published = true
      order by student.studentCode, assignment.subject.displayOrder, result.type, result.sequenceNumber
      """)
  List<AssessmentResult> findAllPublishedWithDetails();

  Optional<AssessmentResult> findByTeachingAssignmentAndStudentAndTypeAndSequenceNumber(
      TeachingAssignment assignment,
      vn.edu.fpt.myfschoolse1913.student.Student student,
      AssessmentType type,
      int sequenceNumber);

  List<AssessmentResult>
      findByTeachingAssignmentOrderByStudentStudentCodeAscTypeAscSequenceNumberAsc(
          TeachingAssignment assignment);

  List<AssessmentResult>
      findByStudentAndPublishedTrueOrderByTeachingAssignmentSubjectDisplayOrderAscTypeAscSequenceNumberAsc(
          vn.edu.fpt.myfschoolse1913.student.Student student);
}
