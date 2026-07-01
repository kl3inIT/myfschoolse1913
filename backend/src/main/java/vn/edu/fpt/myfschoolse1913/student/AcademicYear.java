package vn.edu.fpt.myfschoolse1913.student;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "academic_years")
public class AcademicYear {

	@Id
	@GeneratedValue
	private UUID id;

	@Column(nullable = false, unique = true, length = 40)
	private String name;

	@Column(name = "starts_on")
	private LocalDate startsOn;

	@Column(name = "ends_on")
	private LocalDate endsOn;

	@Column(name = "current_year", nullable = false)
	private boolean currentYear;

	protected AcademicYear() {
	}

	public AcademicYear(String name, LocalDate startsOn, LocalDate endsOn, boolean currentYear) {
		this.name = name;
		this.startsOn = startsOn;
		this.endsOn = endsOn;
		this.currentYear = currentYear;
	}

	public UUID getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public boolean isCurrentYear() {
		return currentYear;
	}
}
