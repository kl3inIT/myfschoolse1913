package vn.edu.fpt.myfschoolse1913.bootstrap;

import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import vn.edu.fpt.myfschoolse1913.user.AppUser;
import vn.edu.fpt.myfschoolse1913.user.AppUserRepository;
import vn.edu.fpt.myfschoolse1913.user.UserRole;

@Configuration
@ConditionalOnProperty(prefix = "app.bootstrap.demo-user", name = "enabled", havingValue = "true")
public class DemoUserSeeder {

	@Bean
	@Order(0)
	ApplicationRunner seedDemoStudent(AppUserRepository userRepository, PasswordEncoder passwordEncoder) {
		return (args) -> {
			String passwordHash = passwordEncoder.encode(DemoStudentFixtures.DEFAULT_PASSWORD);
			seedUser(
					userRepository,
					DemoStudentFixtures.ADMIN_PHONE,
					passwordHash,
					"Quản trị viên",
					UserRole.ADMIN,
					true
			);
			for (var fixture : DemoStudentFixtures.STUDENTS) {
				seedUser(
						userRepository,
						fixture.phoneNumber(),
						passwordHash,
						fixture.fullName(),
						UserRole.STUDENT,
						fixture.enabled()
				);
			}
		};
	}

	private AppUser seedUser(
			AppUserRepository userRepository,
			String phoneNumber,
			String passwordHash,
			String fullName,
			UserRole role,
			boolean enabled
	) {
		var user = userRepository.findByPhoneNumber(phoneNumber)
				.orElseGet(() -> userRepository.save(new AppUser(
						phoneNumber,
						passwordHash,
						fullName,
						role
				)));
		user.updateFullName(fullName);
		user.updateEnabled(enabled);
		return userRepository.save(user);
	}
}
