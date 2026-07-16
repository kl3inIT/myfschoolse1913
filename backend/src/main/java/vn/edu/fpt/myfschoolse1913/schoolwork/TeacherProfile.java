package vn.edu.fpt.myfschoolse1913.schoolwork;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import vn.edu.fpt.myfschoolse1913.user.AppUser;

@Entity
@Table(name = "teacher_profiles")
public class TeacherProfile {

  @Id @GeneratedValue private UUID id;

  @OneToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "user_id", nullable = false, unique = true)
  private AppUser user;

  @Column(name = "employee_code", nullable = false, unique = true, length = 40)
  private String employeeCode;

  @Column(nullable = false, length = 30)
  private String status = "ACTIVE";

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt = Instant.now();

  protected TeacherProfile() {}

  public TeacherProfile(AppUser user, String employeeCode) {
    this.user = user;
    this.employeeCode = employeeCode;
  }

  public UUID getId() {
    return id;
  }

  public AppUser getUser() {
    return user;
  }

  public String getEmployeeCode() {
    return employeeCode;
  }

  public String getStatus() {
    return status;
  }

  public void update(String employeeCode, String status) {
    this.employeeCode = employeeCode;
    this.status = status;
    this.updatedAt = Instant.now();
  }
}
