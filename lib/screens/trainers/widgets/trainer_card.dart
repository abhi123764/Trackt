import 'dart:io';

import 'package:flutter/material.dart';

import '../../../models/trainer.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';

class TrainerCard extends StatelessWidget {
  final Trainer trainer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const TrainerCard({
    super.key,
    required this.trainer,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = trainer.salaryStatus;
    final bool isPaid = status.isPaid;
    final String nextDateStr = AppFormatters.formatDisplayDate(
      status.nextPaymentDate,
      dayFirst: true,
    );
    final bool hasPhoto = trainer.profilePhotoPath != null &&
        File(trainer.profilePhotoPath!).existsSync();

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
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
                      backgroundImage:
                          hasPhoto ? FileImage(File(trainer.profilePhotoPath!)) : null,
                      child: hasPhoto
                          ? null
                          : Text(
                              AppFormatters.getInitials(trainer.name),
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
                            : '₹${AppFormatters.formatAmount(trainer.salary, decimals: 2)}',
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
                          '₹${AppFormatters.formatAmount(trainer.salary, decimals: 2)} / month',
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
}
