package vn.edu.fpt.myfschoolse1913.security;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.auth")
public record AuthProperties(
		Duration accessTokenTtl,
		Duration refreshTokenTtl
) {
}
