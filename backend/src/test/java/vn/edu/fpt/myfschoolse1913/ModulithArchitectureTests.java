package vn.edu.fpt.myfschoolse1913;

import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;

class ModulithArchitectureTests {

	@Test
	void verifiesApplicationModuleBoundaries() {
		ApplicationModules.of(Myfschoolse1913BackendApplication.class).verify();
	}
}
