package vn.edu.fpt.myfschoolse1913.security;

import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

@Configuration
public class JwtKeyConfig {

	@Bean
	KeyPair jwtKeyPair(
			@Value("${app.security.jwt.private-key-location:}") String privateKeyLocation,
			@Value("${app.security.jwt.public-key-location:}") String publicKeyLocation,
			ResourceLoader resourceLoader,
			Environment environment
	) {
		boolean hasPrivateKey = !privateKeyLocation.isBlank();
		boolean hasPublicKey = !publicKeyLocation.isBlank();
		if (hasPrivateKey != hasPublicKey) {
			throw new IllegalStateException("Both JWT private and public key locations must be configured");
		}
		if (hasPrivateKey) {
			return loadKeyPair(
					resourceLoader.getResource(privateKeyLocation),
					resourceLoader.getResource(publicKeyLocation)
			);
		}
		if (environment.acceptsProfiles(Profiles.of("prod"))) {
			throw new IllegalStateException("Persistent JWT keys are required in the prod profile");
		}
		return generateKeyPair();
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

	private KeyPair generateKeyPair() {
		try {
			var generator = KeyPairGenerator.getInstance("RSA");
			generator.initialize(2048);
			return generator.generateKeyPair();
		}
		catch (Exception exception) {
			throw new IllegalStateException("Could not generate JWT key pair", exception);
		}
	}

	private KeyPair loadKeyPair(Resource privateKeyResource, Resource publicKeyResource) {
		try {
			var keyFactory = KeyFactory.getInstance("RSA");
			var privateKey = (RSAPrivateKey) keyFactory.generatePrivate(
					new PKCS8EncodedKeySpec(readPem(privateKeyResource, "PRIVATE KEY"))
			);
			var publicKey = (RSAPublicKey) keyFactory.generatePublic(
					new X509EncodedKeySpec(readPem(publicKeyResource, "PUBLIC KEY"))
			);
			return new KeyPair(publicKey, privateKey);
		}
		catch (Exception exception) {
			throw new IllegalStateException("Could not load JWT key pair", exception);
		}
	}

	private byte[] readPem(Resource resource, String type) throws Exception {
		try (var input = resource.getInputStream()) {
			var pem = new String(input.readAllBytes(), StandardCharsets.US_ASCII)
					.replace("-----BEGIN " + type + "-----", "")
					.replace("-----END " + type + "-----", "")
					.replaceAll("\\s", "");
			return Base64.getDecoder().decode(pem);
		}
	}
}
