import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../utils/formatters.dart';

class AttendanceFilterSheet extends StatefulWidget {
  const AttendanceFilterSheet({super.key});

  @override
  State<AttendanceFilterSheet> createState() => _AttendanceFilterSheetState();
}

class _AttendanceFilterSheetState extends State<AttendanceFilterSheet> {
  late String _selectedStatus;
  late int? _selectedPlan;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AttendanceProvider>();
    _selectedStatus = provider.statusFilter;
    _selectedPlan = provider.planFilter;
    _selectedDate = provider.selectedDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF054446),
              onPrimary: Colors.white,
              onSurface: Color(0xFF101828),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final plans = provider.membershipPlans;

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
                'Filter Attendance',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = 'All';
                    _selectedPlan = null;
                    _selectedDate = DateTime.now();
                  });
                },
                child: const Text(
                  'Reset All',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD92D20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Selector
          const Text(
            'DATE',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Color(0xFF054446)),
                  const SizedBox(width: 10),
                  Text(
                    AppFormatters.formatDisplayDate(_selectedDate),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF667085)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status Filter
          const Text(
            'ATTENDANCE STATUS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['All', 'Present', 'Absent', 'Expired'].map((status) {
              final isSelected = _selectedStatus == status;
              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                selectedColor: const Color(0xFF054446),
                backgroundColor: const Color(0xFFF2F4F7),
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF344054),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedStatus = status;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Plan Filter
          const Text(
            'MEMBERSHIP PLAN',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All Plans'),
                selected: _selectedPlan == null,
                selectedColor: const Color(0xFF054446),
                backgroundColor: const Color(0xFFF2F4F7),
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: _selectedPlan == null ? FontWeight.w700 : FontWeight.w500,
                  color: _selectedPlan == null ? Colors.white : const Color(0xFF344054),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPlan = null;
                    });
                  }
                },
              ),
              ...plans.map((p) {
                final isSelected = _selectedPlan == p.id;
                return ChoiceChip(
                  label: Text(p.name),
                  selected: isSelected,
                  selectedColor: const Color(0xFF054446),
                  backgroundColor: const Color(0xFFF2F4F7),
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF344054),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedPlan = selected ? p.id : null;
                    });
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final attProvider = context.read<AttendanceProvider>();
                attProvider.setStatusFilter(_selectedStatus);
                attProvider.setPlanFilter(_selectedPlan);
                if (_selectedDate != attProvider.selectedDate) {
                  attProvider.setSelectedDate(_selectedDate);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF054446),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
