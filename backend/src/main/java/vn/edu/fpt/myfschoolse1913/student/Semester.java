package vn.edu.fpt.myfschoolse1913.student;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "semesters")
public class Semester {

	@Id
	@GeneratedValue
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "academic_year_id", nullable = false)
	private AcademicYear academicYear;

	@Column(nullable = false, length = 40)
	private String name;

	@Column(name = "display_order", nullable = false)
	private int displayOrder;

	@Column(name = "starts_on")
	private LocalDate startsOn;

	@Column(name = "ends_on")
	private LocalDate endsOn;

	@Column(name = "current_semester", nullable = false)
	private boolean currentSemester;

	protected Semester() {
	}

	public Semester(AcademicYear academicYear, String name, int displayOrder, LocalDate startsOn, LocalDate endsOn, boolean currentSemester) {
		this.academicYear = academicYear;
		this.name = name;
		this.displayOrder = displayOrder;
		this.startsOn = startsOn;
		this.endsOn = endsOn;
		this.currentSemester = currentSemester;
	}

	public UUID getId() {
		return id;
	}

	public String getName() {
		return name;
	}
}
