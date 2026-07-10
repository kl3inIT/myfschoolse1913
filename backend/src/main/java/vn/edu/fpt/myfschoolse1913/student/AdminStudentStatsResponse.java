package vn.edu.fpt.myfschoolse1913.student;

public record AdminStudentStatsResponse(
		long totalStudents,
		long activeStudents,
		long lockedAccounts,
		long totalClasses
) {
}
