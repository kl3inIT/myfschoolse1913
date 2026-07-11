package vn.edu.fpt.myfschoolse1913.bootstrap;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Set;
import java.util.stream.Collectors;
import org.junit.jupiter.api.Test;

class DemoStudentFixturesTests {

	@Test
	void definesThirtySixUniqueStudentsAcrossThreeClasses() {
		var fixtures = DemoStudentFixtures.STUDENTS;

		assertEquals(36, fixtures.size());
		assertEquals(36, fixtures.stream().map(DemoStudentFixtures.StudentFixture::phoneNumber).distinct().count());
		assertEquals(36, fixtures.stream().map(DemoStudentFixtures.StudentFixture::studentCode).distinct().count());
		assertEquals(
				Set.of("10A1", "10A2", "11A1"),
				fixtures.stream()
						.map(DemoStudentFixtures.StudentFixture::className)
						.collect(Collectors.toSet())
		);
		for (String className : Set.of("10A1", "10A2", "11A1")) {
			assertEquals(12, fixtures.stream().filter((fixture) -> fixture.className().equals(className)).count());
		}
	}

	@Test
	void keepsTheDocumentedDemoStudentAsTheFirstActiveFixture() {
		var demoStudent = DemoStudentFixtures.STUDENTS.getFirst();

		assertEquals(DemoStudentFixtures.DEMO_STUDENT_PHONE, demoStudent.phoneNumber());
		assertEquals("Nguyễn Minh Anh", demoStudent.fullName());
		assertEquals("10A1", demoStudent.className());
		assertTrue(demoStudent.enabled());
	}
}
