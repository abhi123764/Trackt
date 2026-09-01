import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/member_provider.dart';
import '../../../theme/app_theme.dart';

class MemberFilterSheet extends StatelessWidget {
  const MemberFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Members',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tealDark,
                      ),
                    ),
                    if (provider.statusFilter != 'All' ||
                        provider.genderFilter != 'All' ||
                        provider.planFilter != null)
                      TextButton(
                        onPressed: provider.resetFilters,
                        child: const Text('Reset All'),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Status Filter Section
                const Text('STATUS', style: AppTextStyles.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Active', 'Inactive'].map((status) {
                    final isSelected = provider.statusFilter == status;
                    return ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: AppColors.tealPrimary,
                      backgroundColor: AppColors.inputFill,
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      onSelected: (_) => provider.setStatusFilter(status),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Gender Filter Section
                const Text('GENDER', style: AppTextStyles.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Male', 'Female', 'Other'].map((gender) {
                    final isSelected = provider.genderFilter == gender;
                    return ChoiceChip(
                      label: Text(gender),
                      selected: isSelected,
                      selectedColor: AppColors.tealPrimary,
                      backgroundColor: AppColors.inputFill,
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      onSelected: (_) => provider.setGenderFilter(gender),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
