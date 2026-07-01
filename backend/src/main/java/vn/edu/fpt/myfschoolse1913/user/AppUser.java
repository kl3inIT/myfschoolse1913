package vn.edu.fpt.myfschoolse1913.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "app_users")
public class AppUser {

	@Id
	@GeneratedValue
	private UUID id;

	@Column(name = "phone_number", nullable = false, unique = true, length = 20)
	private String phoneNumber;

	@Column(name = "password_hash", nullable = false)
	private String passwordHash;

	@Column(name = "full_name", nullable = false, length = 120)
	private String fullName;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 20)
	private UserRole role;

	@Column(nullable = false)
	private boolean enabled = true;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt = Instant.now();

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt = Instant.now();

	protected AppUser() {
	}

	public AppUser(String phoneNumber, String passwordHash, String fullName, UserRole role) {
		this.phoneNumber = phoneNumber;
		this.passwordHash = passwordHash;
		this.fullName = fullName;
		this.role = role;
	}

	public UUID getId() {
		return id;
	}

	public String getPhoneNumber() {
		return phoneNumber;
	}

	public String getPasswordHash() {
		return passwordHash;
	}

	public String getFullName() {
		return fullName;
	}

	public UserRole getRole() {
		return role;
	}

	public boolean isEnabled() {
		return enabled;
	}

	public void updatePasswordHash(String passwordHash) {
		this.passwordHash = passwordHash;
		this.updatedAt = Instant.now();
	}
}
