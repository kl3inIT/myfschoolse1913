package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record GuardianLinkRequest(
    @NotNull UUID parentId,
    @NotNull UUID studentId,
    @NotNull GuardianRelationship relationship,
    boolean primaryContact,
    boolean active) {}
