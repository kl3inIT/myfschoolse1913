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
			userRepository.findByPhoneNumber("0900000000")
					.orElseGet(() -> userRepository.save(new AppUser(
							"0900000000",
							passwordEncoder.encode("Password123"),
							"Quản trị viên",
							UserRole.ADMIN
					)));

			userRepository.findByPhoneNumber("0900000001")
					.orElseGet(() -> userRepository.save(new AppUser(
							"0900000001",
							passwordEncoder.encode("Password123"),
							"Nguyễn Minh Anh",
							UserRole.STUDENT
					)));
		};
	}
}
