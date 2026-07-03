package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;

public record StudentSemesterGradesResponse(
		String academicYear,
		String semester,
		String className,
		double averageScore,
		String rank,
		String note,
		List<SubjectGrade> subjects
) {

	public record SubjectGrade(
			String name,
			double formativeScore,
			double midtermScore,
			double finalScore,
			double score,
			String status,
			String detail,
			String teacherComment
	) {
	}
}
