import 'package:flutter/material.dart';

import '../../../models/trainer.dart';
import '../../../theme/app_theme.dart';

class TrainerCard extends StatelessWidget {
  final Trainer trainer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TrainerCard({
    super.key,
    required this.trainer,
    required this.onEdit,
    required this.onDelete,
  });

  /// Computes salary payment status from the trainer's joining date.
  ///
  /// Salary is paid on the same calendar day every month (the joining day).
  /// - If today is BEFORE the next due date → PAID (payment not yet due).
  /// - If today is ON or AFTER the next due date → DUE.
  ///
  /// Returns a record: (isPaid, nextPaymentDate).
  ({bool isPaid, DateTime nextPaymentDate}) get _salaryStatus {
    final today = DateTime.now();

    // Try parsing the stored joiningDate.  It may be ISO (YYYY-MM-DD) or
    // mm/dd/yyyy depending on how the user entered it.
    DateTime? joined = _parseDate(trainer.joiningDate);
    joined ??= today; // fallback: treat as just joined → paid

    // Find the next payment date after today.
    // Start from the joining month in the current year and step forward.
    int year = today.year;
    int month = today.month;
    final payDay = joined.day.clamp(1, 28); // safe across all months

    DateTime candidate = DateTime(year, month, payDay);

    // If this month's payment date has already passed (or is today → DUE),
    // move to next month.
    if (today.isBefore(candidate)) {
      // today < candidate → this month's payment hasn't come yet → PAID
      return (isPaid: true, nextPaymentDate: candidate);
    } else {
      // today >= candidate → payment is due or overdue
      // Compute the NEXT month's date so we can show it when paid next time.
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextYear = month == 12 ? year + 1 : year;
      final nextCandidate = DateTime(nextYear, nextMonth, payDay);
      return (isPaid: false, nextPaymentDate: nextCandidate);
    }
  }

  static DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    // ISO format: YYYY-MM-DD
    if (raw.contains('-') && raw.length == 10) {
      return DateTime.tryParse(raw);
    }
    // mm/dd/yyyy or dd/mm/yyyy (we stored as mm/dd/yyyy in pickers)
    final parts = raw.split('/');
    if (parts.length == 3) {
      final a = int.tryParse(parts[0]);
      final b = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (a != null && b != null && y != null && y > 1900) {
        return DateTime(y, a, b); // mm/dd/yyyy
      }
    }
    return DateTime.tryParse(raw);
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final status = _salaryStatus;
    final bool isPaid = status.isPaid;
    final String nextDateStr = _formatDate(status.nextPaymentDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP ROW: Avatar + Name/Specialty + Edit icon ──────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _avatarBg,
                  child: Text(
                    _initials,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _avatarFg,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101828),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trainer.qualification ?? trainer.experience ?? 'Trainer',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          color: Color(0xFF667085),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Edit pencil
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Color(0xFF667085),
                  ),
                  onSelected: (val) {
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Delete Trainer',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF2F4F7)),
            const SizedBox(height: 12),

            // ── BOTTOM ROW: Salary info + status badge ────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label changes based on status
                      Text(
                        isPaid ? 'Next Payment' : 'Salary Due',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF98A2B3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Value: date when paid, amount when due
                      Text(
                        isPaid
                            ? nextDateStr
                            : '₹${_formatSalary(trainer.salary)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: isPaid ? 17 : 22,
                          fontWeight: FontWeight.w800,
                          color: isPaid
                              ? const Color(0xFF027A48)
                              : const Color(0xFF101828),
                        ),
                      ),
                      // When paid, also show the salary amount as a subtitle
                      if (isPaid) ...[
                        const SizedBox(height: 2),
                        Text(
                          '₹${_formatSalary(trainer.salary)} / month',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusBadge(isPaid),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStatusBadge(bool paid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: paid
            ? const Color(0xFF12B76A)
            : const Color(0xFFFEE4E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        paid ? 'PAID' : 'DUE',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: paid ? Colors.white : const Color(0xFFD92D20),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String get _initials {
    final parts = trainer.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  // Cycle through a few nice avatar colours deterministically
  static const List<Color> _bgPalette = [
    Color(0xFFDCEEFE),
    Color(0xFFEDE9FE),
    Color(0xFFD1FADF),
    Color(0xFFFEF0C7),
    Color(0xFFFFE4E8),
  ];
  static const List<Color> _fgPalette = [
    Color(0xFF1570EF),
    Color(0xFF6941C6),
    Color(0xFF027A48),
    Color(0xFFB54708),
    Color(0xFFC01048),
  ];

  Color get _avatarBg {
    final idx = (trainer.id ?? 0) % _bgPalette.length;
    return _bgPalette[idx];
  }

  Color get _avatarFg {
    final idx = (trainer.id ?? 0) % _fgPalette.length;
    return _fgPalette[idx];
  }

  String _formatSalary(double salary) {
    if (salary >= 1000) {
      return salary.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return salary.toStringAsFixed(2);
  }
}
