package vn.edu.fpt.myfschoolse1913.shared;

public class RateLimitExceededException extends RuntimeException {

	public RateLimitExceededException(String message) {
		super(message);
	}
}
