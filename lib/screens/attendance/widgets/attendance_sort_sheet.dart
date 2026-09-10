import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/attendance_provider.dart';

class AttendanceSortSheet extends StatelessWidget {
  const AttendanceSortSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final currentOption = provider.sortOption;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFEAECF0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort Members',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              if (provider.isSorted)
                TextButton(
                  onPressed: () {
                    provider.setSortOption(AttendanceSortOption.nameAsc);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF054446),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...AttendanceSortOption.values.map((option) {
            final isSelected = currentOption == option;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? const Color(0xFF054446) : const Color(0xFF98A2B3),
              ),
              title: Text(
                option.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF054446) : const Color(0xFF344054),
                ),
              ),
              onTap: () {
                provider.setSortOption(option);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}
