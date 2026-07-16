package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

public final class VietnameseGradeCalculator {
  private VietnameseGradeCalculator() {}

  public static BigDecimal semesterAverage(
      List<BigDecimal> regularScores, BigDecimal midtermScore, BigDecimal finalScore) {
    if (regularScores.isEmpty() || midtermScore == null || finalScore == null) {
      return null;
    }
    var total =
        regularScores.stream()
            .reduce(BigDecimal.ZERO, BigDecimal::add)
            .add(midtermScore.multiply(BigDecimal.TWO))
            .add(finalScore.multiply(BigDecimal.valueOf(3)));
    return total.divide(BigDecimal.valueOf(regularScores.size() + 5L), 1, RoundingMode.HALF_UP);
  }

  public static BigDecimal regularAverage(List<BigDecimal> regularScores) {
    if (regularScores.isEmpty()) {
      return null;
    }
    return regularScores.stream()
        .reduce(BigDecimal.ZERO, BigDecimal::add)
        .divide(BigDecimal.valueOf(regularScores.size()), 1, RoundingMode.HALF_UP);
  }
}
