package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.student.Student;

@Entity
@Table(name = "student_guardians")
public class StudentGuardian {

  @Id @GeneratedValue private UUID id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "parent_id", nullable = false)
  private ParentProfile parent;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "student_id", nullable = false)
  private Student student;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 30)
  private GuardianRelationship relationship;

  @Column(name = "primary_contact", nullable = false)
  private boolean primaryContact;

  @Column(name = "verified_at", nullable = false)
  private Instant verifiedAt;

  @Column(nullable = false)
  private boolean active = true;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt = Instant.now();

  protected StudentGuardian() {}

  public StudentGuardian(
      ParentProfile parent,
      Student student,
      GuardianRelationship relationship,
      boolean primaryContact) {
    this.parent = parent;
    this.student = student;
    this.relationship = relationship;
    this.primaryContact = primaryContact;
    this.verifiedAt = Instant.now();
  }

  public UUID getId() {
    return id;
  }

  public ParentProfile getParent() {
    return parent;
  }

  public Student getStudent() {
    return student;
  }

  public GuardianRelationship getRelationship() {
    return relationship;
  }

  public boolean isPrimaryContact() {
    return primaryContact;
  }

  public boolean isActive() {
    return active;
  }

  public void update(GuardianRelationship relationship, boolean primaryContact, boolean active) {
    this.relationship = relationship;
    this.primaryContact = primaryContact;
    this.active = active;
    if (active) this.verifiedAt = Instant.now();
    this.updatedAt = Instant.now();
  }
}
