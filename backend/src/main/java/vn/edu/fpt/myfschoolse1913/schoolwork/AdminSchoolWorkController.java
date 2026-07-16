package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/school-work")
public class AdminSchoolWorkController {
  private final AdminSchoolWorkService service;

  public AdminSchoolWorkController(AdminSchoolWorkService service) {
    this.service = service;
  }

  @GetMapping
  public AdminSchoolWorkResponse overview() {
    return service.overview();
  }

  @PostMapping("/teachers")
  @ResponseStatus(HttpStatus.CREATED)
  public AdminSchoolWorkResponse.TeacherItem createTeacher(
      @Valid @RequestBody CreateTeacherRequest request) {
    return service.createTeacher(request);
  }

  @PostMapping("/parents")
  @ResponseStatus(HttpStatus.CREATED)
  public AdminSchoolWorkResponse.ParentItem createParent(
      @Valid @RequestBody CreateParentRequest request) {
    return service.createParent(request);
  }

  @PostMapping("/teaching-assignments")
  public AdminSchoolWorkResponse.TeachingAssignmentItem assignTeacher(
      @Valid @RequestBody TeachingAssignmentRequest request) {
    return service.assignTeacher(request);
  }

  @PostMapping("/homeroom-assignments")
  public AdminSchoolWorkResponse.HomeroomAssignmentItem assignHomeroom(
      @Valid @RequestBody HomeroomAssignmentRequest request) {
    return service.assignHomeroom(request);
  }

  @PostMapping("/guardian-links")
  public AdminSchoolWorkResponse.GuardianLinkItem linkGuardian(
      @Valid @RequestBody GuardianLinkRequest request) {
    return service.linkGuardian(request);
  }

  @PostMapping("/assessment-results/{resultId}/correction")
  public AdminSchoolWorkResponse.AssessmentItem correctPublishedAssessment(
      @AuthenticationPrincipal Jwt jwt,
      @org.springframework.web.bind.annotation.PathVariable UUID resultId,
      @Valid @RequestBody AdminAssessmentCorrectionRequest request) {
    return service.correctPublishedAssessment(UUID.fromString(jwt.getSubject()), resultId, request);
  }
}
