package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/teachers/me")
public class TeacherSchoolWorkController {
  private final TeacherSchoolWorkService service;

  public TeacherSchoolWorkController(TeacherSchoolWorkService service) {
    this.service = service;
  }

  @GetMapping("/workspace")
  public TeacherWorkspaceResponse workspace(@AuthenticationPrincipal Jwt jwt) {
    return service.workspace(userId(jwt));
  }

  @GetMapping("/assignments/{assignmentId}/classroom")
  public TeacherClassroomResponse classroom(
      @AuthenticationPrincipal Jwt jwt,
      @PathVariable UUID assignmentId,
      @RequestParam LocalDate date,
      @RequestParam(defaultValue = "1") int lessonNumber) {
    return service.classroom(userId(jwt), assignmentId, date, lessonNumber);
  }

  @PutMapping("/assignments/{assignmentId}/attendance")
  public TeacherClassroomResponse attendance(
      @AuthenticationPrincipal Jwt jwt,
      @PathVariable UUID assignmentId,
      @Valid @RequestBody AttendanceBatchRequest request) {
    return service.saveAttendance(userId(jwt), assignmentId, request);
  }

  @PutMapping("/assignments/{assignmentId}/grades")
  public TeacherClassroomResponse grades(
      @AuthenticationPrincipal Jwt jwt,
      @PathVariable UUID assignmentId,
      @Valid @RequestBody GradeBatchRequest request) {
    return service.saveGrades(userId(jwt), assignmentId, request);
  }

  @GetMapping("/homeroom/{classId}/applications")
  public TeacherApplicationsResponse applications(
      @AuthenticationPrincipal Jwt jwt, @PathVariable UUID classId) {
    return service.homeroomApplications(userId(jwt), classId);
  }

  @PutMapping("/homeroom/{classId}/applications/{applicationId}")
  public TeacherApplicationsResponse.Item review(
      @AuthenticationPrincipal Jwt jwt,
      @PathVariable UUID classId,
      @PathVariable UUID applicationId,
      @Valid @RequestBody TeacherApplicationReviewRequest request) {
    return service.reviewApplication(userId(jwt), classId, applicationId, request);
  }

  @PutMapping("/homeroom/{classId}/conduct")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void conduct(
      @AuthenticationPrincipal Jwt jwt,
      @PathVariable UUID classId,
      @Valid @RequestBody ConductBatchRequest request) {
    service.saveConduct(userId(jwt), classId, request);
  }

  private UUID userId(Jwt jwt) {
    return UUID.fromString(jwt.getSubject());
  }
}
