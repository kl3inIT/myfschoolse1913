package vn.edu.fpt.myfschoolse1913.student;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "school_classes")
public class SchoolClass {

	@Id
	@GeneratedValue
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "academic_year_id", nullable = false)
	private AcademicYear academicYear;

	@Column(nullable = false, length = 40)
	private String name;

	protected SchoolClass() {
	}

	public SchoolClass(AcademicYear academicYear, String name) {
		this.academicYear = academicYear;
		this.name = name;
	}

	public UUID getId() {
		return id;
	}

	public AcademicYear getAcademicYear() {
		return academicYear;
	}

	public String getName() {
		return name;
	}
}
