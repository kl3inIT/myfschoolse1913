package vn.edu.fpt.myfschoolse1913.application;

public record AdminApplicationStatsResponse(
		long totalApplications,
		long pendingApplications,
		long approvedApplications,
		long rejectedApplications
) {
}
