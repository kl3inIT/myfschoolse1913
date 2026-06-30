package vn.edu.fpt.myfschoolse1913.security;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

@Configuration
public class JwtKeyConfig {

	@Bean
	KeyPair jwtKeyPair() {
		try {
			var generator = KeyPairGenerator.getInstance("RSA");
			generator.initialize(2048);
			return generator.generateKeyPair();
		}
		catch (Exception exception) {
			throw new IllegalStateException("Could not generate JWT key pair", exception);
		}
	}

	@Bean
	JwtEncoder jwtEncoder(KeyPair jwtKeyPair) {
		return NimbusJwtEncoder.withKeyPair(
				(RSAPublicKey) jwtKeyPair.getPublic(),
				(RSAPrivateKey) jwtKeyPair.getPrivate()
		).build();
	}

	@Bean
	JwtDecoder jwtDecoder(KeyPair jwtKeyPair) {
		return NimbusJwtDecoder.withPublicKey((RSAPublicKey) jwtKeyPair.getPublic()).build();
	}
}
