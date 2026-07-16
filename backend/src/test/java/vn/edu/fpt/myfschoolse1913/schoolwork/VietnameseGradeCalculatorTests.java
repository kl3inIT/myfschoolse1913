package vn.edu.fpt.myfschoolse1913.schoolwork;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.Test;

class VietnameseGradeCalculatorTests {

  @Test
  void calculatesCircular22SemesterAverageWithMultipleRegularScores() {
    var average =
        VietnameseGradeCalculator.semesterAverage(
            List.of(new BigDecimal("8.0"), new BigDecimal("9.0")),
            new BigDecimal("8.0"),
            new BigDecimal("9.0"));

    assertThat(average).isEqualByComparingTo("8.6");
  }

  @Test
  void calculatesRegularAverageForTheLegacyStudentSummary() {
    var average =
        VietnameseGradeCalculator.regularAverage(
            List.of(new BigDecimal("7.0"), new BigDecimal("8.0")));

    assertThat(average).isEqualByComparingTo("7.5");
  }

  @Test
  void doesNotPublishAnAverageUntilRequiredComponentsExist() {
    assertThat(
            VietnameseGradeCalculator.semesterAverage(
                List.of(new BigDecimal("8.0")), null, new BigDecimal("9.0")))
        .isNull();
  }
}
