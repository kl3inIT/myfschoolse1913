package vn.edu.fpt.myfschoolse1913.club;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "school_clubs")
public class SchoolClub {

	@Id
	@GeneratedValue
	private UUID id;

	@Column(nullable = false, unique = true, length = 120)
	private String name;

	@Column(nullable = false, length = 500)
	private String description;

	@Column(name = "schedule_text", nullable = false, length = 160)
	private String scheduleText;

	@Column(nullable = false, length = 120)
	private String location;

	@Column(nullable = false)
	private boolean active = true;

	protected SchoolClub() {
	}

	public SchoolClub(String name, String description, String scheduleText, String location, boolean active) {
		this.name = name;
		this.description = description;
		this.scheduleText = scheduleText;
		this.location = location;
		this.active = active;
	}

	public UUID getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public String getDescription() {
		return description;
	}

	public String getScheduleText() {
		return scheduleText;
	}

	public String getLocation() {
		return location;
	}
}
