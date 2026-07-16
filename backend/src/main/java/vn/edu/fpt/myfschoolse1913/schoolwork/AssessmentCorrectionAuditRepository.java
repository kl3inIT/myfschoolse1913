package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AssessmentCorrectionAuditRepository
    extends JpaRepository<AssessmentCorrectionAudit, UUID> {}
