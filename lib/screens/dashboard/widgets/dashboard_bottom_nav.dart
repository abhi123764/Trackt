import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabSelected;

  const DashboardBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.grid_view_rounded, 'Home'),
      (Icons.groups_outlined, 'Members'),
      (Icons.bar_chart_rounded, 'Reports'),
      (Icons.payments_outlined, 'Payments'),
      (Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final selected = index == currentTab;
            final (icon, label) = items[index];

            return Expanded(
              child: InkWell(
                onTap: () => onTabSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: selected
                            ? AppColors.tealPrimary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? AppColors.tealPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
