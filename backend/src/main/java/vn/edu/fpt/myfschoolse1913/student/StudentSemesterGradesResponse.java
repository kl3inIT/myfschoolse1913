package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;

public record StudentSemesterGradesResponse(
		String semester,
		double averageScore,
		String rank,
		List<SubjectGrade> subjects
) {

	public record SubjectGrade(
			String name,
			double score,
			String detail
	) {
	}
}
