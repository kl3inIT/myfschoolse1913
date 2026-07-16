package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/parents/me")
public class ParentSchoolWorkController {
  private final ParentSchoolWorkService service;

  public ParentSchoolWorkController(ParentSchoolWorkService service) {
    this.service = service;
  }

  @GetMapping("/workspace")
  public ParentWorkspaceResponse workspace(
      @AuthenticationPrincipal Jwt jwt, @RequestParam(required = false) UUID studentId) {
    return service.workspace(userId(jwt), studentId);
  }

  @PostMapping("/children/{studentId}/applications")
  @ResponseStatus(HttpStatus.CREATED)
  public ParentWorkspaceResponse.ApplicationItem createApplication(
      @AuthenticationPrincipal Jwt jwt,
      @PathVariable UUID studentId,
      @Valid @RequestBody CreateParentApplicationRequest request) {
    return service.createApplication(userId(jwt), studentId, request);
  }

  private UUID userId(Jwt jwt) {
    return UUID.fromString(jwt.getSubject());
  }
}
