/// Formatting utilities for currency, numbers, and dates.
class AppFormatters {
  AppFormatters._();

  /// Formats monetary amounts with currency symbols (e.g. ₹10.5K, ₹1.2M, ₹500).
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₹${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  /// Formats a DateTime object into MM/DD/YYYY string format.
  static String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }
}
