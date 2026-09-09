class HealthCalculators {
  /// Returns null if height/weight are invalid.
  static double? calculateBmi({
    required double? heightCm,
    required double? weightKg,
  }) {
    if (heightCm == null || weightKg == null || heightCm <= 0) return null;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
}
