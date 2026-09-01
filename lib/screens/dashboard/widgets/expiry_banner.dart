import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ExpiryBanner extends StatelessWidget {
  const ExpiryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.timer_outlined, color: AppColors.danger, size: 26),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memberships Expiring Soon',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Expiry tracking will be connected to membership data.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.danger),
        ],
      ),
    );
  }
}
