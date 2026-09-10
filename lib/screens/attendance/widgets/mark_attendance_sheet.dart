import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/member.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../utils/formatters.dart';

class MarkAttendanceSheet extends StatefulWidget {
  const MarkAttendanceSheet({super.key});

  @override
  State<MarkAttendanceSheet> createState() => _MarkAttendanceSheetState();
}

class _MarkAttendanceSheetState extends State<MarkAttendanceSheet> {
  Member? _selectedMember;
  DateTime _date = DateTime.now();
  TimeOfDay _checkInTime = TimeOfDay.now();
  TimeOfDay? _checkOutTime;
  bool _isSaving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
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
      setState(() => _date = picked);
    }
  }

  Future<void> _pickCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime,
    );
    if (picked != null) {
      setState(() => _checkInTime = picked);
    }
  }

  Future<void> _pickCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _checkOutTime = picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return AppFormatters.formatTime(dt);
  }

  Future<void> _save() async {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final inTimeStr = _formatTimeOfDay(_checkInTime);
      final outTimeStr = _checkOutTime != null ? _formatTimeOfDay(_checkOutTime!) : null;

      final attProvider = context.read<AttendanceProvider>();
      await attProvider.checkInMember(
        _selectedMember!.id!,
        checkInTime: inTimeStr,
        date: _date,
      );

      if (outTimeStr != null) {
        await attProvider.checkOutMember(
          _selectedMember!.id!,
          checkOutTime: outTimeStr,
          date: _date,
        );
      }

      // Sync member provider
      if (mounted) {
        context.read<MemberProvider>().fetchMembers();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance recorded for ${_selectedMember!.name}'),
            backgroundColor: const Color(0xFF054446),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save attendance: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attProvider = context.watch<AttendanceProvider>();
    final members = attProvider.items.map((i) => i.member).toList();

    AttendanceMemberItem? selectedItem;
    if (_selectedMember != null) {
      for (final item in attProvider.items) {
        if (item.member.id == _selectedMember!.id) {
          selectedItem = item;
          break;
        }
      }
    }

    final bool isAlreadyCompleted = selectedItem != null &&
        selectedItem.todayAttendance?.checkIn != null &&
        selectedItem.todayAttendance?.checkOut != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
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
              const Text(
                'Mark Member Attendance',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 16),

              // Member selector
              const Text(
                'MEMBER',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Member>(
                    isExpanded: true,
                    hint: const Text('Select a member'),
                    value: _selectedMember,
                    items: members.map((m) {
                      return DropdownMenuItem<Member>(
                        value: m,
                        child: Text(
                          m.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101828),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedMember = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date
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
                        AppFormatters.formatDisplayDate(_date),
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

              // Check-In and Check-Out Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHECK-IN TIME',
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
                          onTap: _pickCheckInTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEAECF0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 18, color: Color(0xFF054446)),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimeOfDay(_checkInTime),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF101828),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHECK-OUT TIME',
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
                          onTap: _pickCheckOutTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEAECF0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_filled, size: 18, color: Color(0xFF667085)),
                                const SizedBox(width: 8),
                                Text(
                                  _checkOutTime != null
                                      ? _formatTimeOfDay(_checkOutTime!)
                                      : 'Optional',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _checkOutTime != null
                                        ? const Color(0xFF101828)
                                        : const Color(0xFF98A2B3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save Button
              if (isAlreadyCompleted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Attendance marked: IN ${selectedItem.checkInTime} • OUT ${selectedItem.checkOutTime}\nNo update needed.',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF054446),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Attendance',
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
        ),
      ),
    );
  }
}
