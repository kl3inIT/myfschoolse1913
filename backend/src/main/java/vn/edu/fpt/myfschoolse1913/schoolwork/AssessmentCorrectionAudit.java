package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.user.AppUser;

@Entity
@Table(name = "assessment_correction_audits")
public class AssessmentCorrectionAudit {

  @Id @GeneratedValue private UUID id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "assessment_result_id", nullable = false)
  private AssessmentResult assessmentResult;

  @Column(name = "previous_score", precision = 4, scale = 1)
  private BigDecimal previousScore;

  @Column(name = "new_score", nullable = false, precision = 4, scale = 1)
  private BigDecimal newScore;

  @Column(name = "previous_comment", length = 255)
  private String previousComment;

  @Column(name = "new_comment", length = 255)
  private String newComment;

  @Column(nullable = false, length = 500)
  private String reason;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "corrected_by", nullable = false)
  private AppUser correctedBy;

  @Column(name = "corrected_at", nullable = false)
  private Instant correctedAt = Instant.now();

  protected AssessmentCorrectionAudit() {}

  public AssessmentCorrectionAudit(
      AssessmentResult result,
      BigDecimal previousScore,
      BigDecimal newScore,
      String previousComment,
      String newComment,
      String reason,
      AppUser correctedBy) {
    this.assessmentResult = result;
    this.previousScore = previousScore;
    this.newScore = newScore;
    this.previousComment = previousComment;
    this.newComment = newComment;
    this.reason = reason;
    this.correctedBy = correctedBy;
  }
}
