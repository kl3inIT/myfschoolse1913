package vn.edu.fpt.myfschoolse1913.security;

import java.util.List;
import java.util.ArrayList;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

	@Bean
	SecurityFilterChain securityFilterChain(
			HttpSecurity http,
			JwtAuthenticationConverter jwtAuthenticationConverter
	) throws Exception {
		http
				.cors(Customizer.withDefaults())
				.csrf(AbstractHttpConfigurer::disable)
				.sessionManagement((session) -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				.authorizeHttpRequests((authorize) -> authorize
						.requestMatchers("/api/auth/**", "/api/health", "/actuator/health/**").permitAll()
						.requestMatchers("/api/admin/**").hasRole("ADMIN")
						.requestMatchers("/api/teachers/**").hasRole("TEACHER")
						.requestMatchers("/api/parents/**").hasRole("PARENT")
						.requestMatchers("/api/students/**").hasRole("STUDENT")
						.anyRequest().authenticated()
				)
				.oauth2ResourceServer((oauth2) -> oauth2.jwt((jwt) -> jwt
						.jwtAuthenticationConverter(jwtAuthenticationConverter)
				));

		return http.build();
	}

	@Bean
	JwtAuthenticationConverter jwtAuthenticationConverter() {
		var scopeAuthoritiesConverter = new JwtGrantedAuthoritiesConverter();
		var jwtAuthenticationConverter = new JwtAuthenticationConverter();
		jwtAuthenticationConverter.setJwtGrantedAuthoritiesConverter((jwt) -> {
			var authorities = new ArrayList<>(scopeAuthoritiesConverter.convert(jwt));
			var role = jwt.getClaimAsString("role");
			if (role != null && !role.isBlank()) {
				authorities.add(new SimpleGrantedAuthority("ROLE_" + role));
			}
			return authorities;
		});
		return jwtAuthenticationConverter;
	}

	@Bean
	PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	@Bean
	CorsConfigurationSource corsConfigurationSource(
			@Value("${app.cors.allowed-origin-patterns}") List<String> allowedOriginPatterns
	) {
		var configuration = new CorsConfiguration();
		configuration.setAllowedOriginPatterns(allowedOriginPatterns);
		configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
		configuration.setAllowedHeaders(List.of("*"));
		configuration.setAllowCredentials(false);

		var source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}
}
