package vn.edu.fpt.myfschoolse1913.notification;

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
@Table(name = "school_notifications")
public class SchoolNotification {

	@Id
	@GeneratedValue
	private UUID id;

	@Column(nullable = false, length = 160)
	private String title;

	@Column(nullable = false, length = 1000)
	private String body;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 40)
	private SchoolNotificationCategory category;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 40)
	private SchoolNotificationAudience audience;

	@Column(name = "published_at", nullable = false)
	private Instant publishedAt;

	@Column(nullable = false)
	private boolean pinned;

	@Column(nullable = false)
	private boolean active = true;

	protected SchoolNotification() {
	}

	public SchoolNotification(
			String title,
			String body,
			SchoolNotificationCategory category,
			SchoolNotificationAudience audience,
			Instant publishedAt,
			boolean pinned,
			boolean active
	) {
		this.title = title;
		this.body = body;
		this.category = category;
		this.audience = audience;
		this.publishedAt = publishedAt;
		this.pinned = pinned;
		this.active = active;
	}

	public UUID getId() {
		return id;
	}

	public String getTitle() {
		return title;
	}

	public String getBody() {
		return body;
	}

	public SchoolNotificationCategory getCategory() {
		return category;
	}

	public Instant getPublishedAt() {
		return publishedAt;
	}

	public boolean isPinned() {
		return pinned;
	}
}
