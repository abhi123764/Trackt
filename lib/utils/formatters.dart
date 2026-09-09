/// Formatting utilities for currency, numbers, and dates.
class AppFormatters {
  AppFormatters._();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

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

  /// Formats numbers with thousand separators (e.g. 1,000 or 15,500).
  static String formatAmount(double amount, {int decimals = 0}) {
    final formatted = decimals > 0
        ? amount.toStringAsFixed(decimals)
        : amount.toStringAsFixed(0);
    if (amount >= 1000) {
      final parts = formatted.split('.');
      final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    }
    return formatted;
  }

  /// Formats a DateTime object into MM/DD/YYYY or DD/MM/YYYY string format.
  static String formatDate(DateTime date, {bool dayFirst = false}) {
    final first = (dayFirst ? date.day : date.month).toString().padLeft(2, '0');
    final second = (dayFirst ? date.month : date.day).toString().padLeft(2, '0');
    return '$first/$second/${date.year}';
  }

  /// Formats date into readable string, e.g. "Jan 01, 2026" or "01 Jan 2026" if [dayFirst] is true.
  static String formatDisplayDate(DateTime date, {bool dayFirst = false}) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    if (dayFirst) {
      return '$day $month ${date.year}';
    }
    return '$month $day, ${date.year}';
  }

  /// Formats time in 12-hour format with AM/PM (e.g. 10:30 AM).
  static String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  /// Safely parses date strings in ISO (YYYY-MM-DD) or slash (MM/DD/YYYY or DD/MM/YYYY) format.
  static DateTime? parseDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains('-') && trimmed.length == 10) {
      return DateTime.tryParse(trimmed);
    }
    final parts = trimmed.split('/');
    if (parts.length == 3) {
      final a = int.tryParse(parts[0]);
      final b = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (a != null && b != null && y != null && y > 1900) {
        return DateTime(y, a, b);
      }
    }
    return DateTime.tryParse(trimmed);
  }

  /// Extracts up to 2 uppercase initials from a person's full name.
  static String getInitials(String name, {String fallback = '?'}) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return fallback;
  }
}
