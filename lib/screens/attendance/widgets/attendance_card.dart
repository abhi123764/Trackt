import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/member.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../utils/formatters.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceMemberItem item;
  final VoidCallback? onTap;

  const AttendanceCard({
    super.key,
    required this.item,
    this.onTap,
  });

  Future<void> _handleCheckIn(BuildContext context) async {
    final memberId = item.member.id;
    if (memberId == null) return;

    final nowStr = AppFormatters.formatTime(DateTime.now());
    final attProvider = context.read<AttendanceProvider>();
    final success = await attProvider.checkInMember(memberId, checkInTime: nowStr);

    if (context.mounted && success) {
      // Sync with MemberProvider as requested by the user
      context.read<MemberProvider>().fetchMembers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checked in ${item.member.name} at $nowStr'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF054446),
        ),
      );
    }
  }

  Future<void> _handleCheckOut(BuildContext context) async {
    final memberId = item.member.id;
    if (memberId == null) return;

    final nowStr = AppFormatters.formatTime(DateTime.now());
    final attProvider = context.read<AttendanceProvider>();
    final success = await attProvider.checkOutMember(memberId, checkOutTime: nowStr);

    if (context.mounted && success) {
      // Sync with MemberProvider as requested by the user
      context.read<MemberProvider>().fetchMembers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checked out ${item.member.name} at $nowStr'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF054446),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = item.member;
    final plan = item.plan;
    final trainer = item.trainer;
    final planName = plan?.name.toUpperCase() ?? 'NORMAL';
    final trainerName = trainer?.name ?? 'Unassigned';

    // Membership status
    final membershipStatus = member.getMembershipStatus(
      planDurationDays: plan?.durationDays ?? 30,
    );
    final bool isExpired = membershipStatus.isExpired;
    final String daysLeftText = membershipStatus.daysLeftText;

    final todayAtt = item.todayAttendance;
    final String? checkInTime = todayAtt?.checkIn;
    final String? checkOutTime = todayAtt?.checkOut;

    final bool hasCheckedIn = checkInTime != null && checkInTime.isNotEmpty;
    final bool hasCheckedOut = checkOutTime != null && checkOutTime.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                // 1. TOP HEADER (Avatar, Name, Plan Pill, Trainer)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAvatar(member, planName),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF101828),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPlanBadge(planName),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Trainer: $trainerName',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF2F4F7)),
                const SizedBox(height: 14),

                // 2. MEMBERSHIP SECTION (Days left & Due/Paid badge)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MEMBERSHIP',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Color(0xFF98A2B3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          daysLeftText,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isExpired
                                ? const Color(0xFFD92D20)
                                : const Color(0xFF054446),
                          ),
                        ),
                      ],
                    ),

                    // Badge: (!) Due or (✓) Paid
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? const Color(0xFFFEE4E2)
                            : const Color(0xFFD1FADF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isExpired
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            size: 14,
                            color: isExpired
                                ? const Color(0xFFD92D20)
                                : const Color(0xFF027A48),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isExpired ? 'Due' : 'Paid',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isExpired
                                  ? const Color(0xFFD92D20)
                                  : const Color(0xFF027A48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 3. ATTENDANCE SECTION (Header & relative info)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ATTENDANCE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        item.lastCheckInText,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          color: Color(0xFF475467),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 4. ACTION ROW
                _buildActionRow(
                  context,
                  hasCheckedIn: hasCheckedIn,
                  hasCheckedOut: hasCheckedOut,
                  checkInTime: checkInTime,
                  checkOutTime: checkOutTime,
                  isExpired: isExpired,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context, {
    required bool hasCheckedIn,
    required bool hasCheckedOut,
    required String? checkInTime,
    required String? checkOutTime,
    required bool isExpired,
  }) {
    // State 1: Both Checked In & Checked Out today
    if (hasCheckedIn && hasCheckedOut) {
      return Row(
        children: [
          Expanded(child: _buildTimeBox('IN', checkInTime!)),
          const SizedBox(width: 12),
          Expanded(child: _buildTimeBox('OUT', checkOutTime!)),
        ],
      );
    }

    // State 2: Checked In only, not yet checked out
    if (hasCheckedIn && !hasCheckedOut) {
      return Row(
        children: [
          Expanded(child: _buildTimeBox('IN', checkInTime!)),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _handleCheckOut(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD0D5DD)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'OUT',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Check-out',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF054446),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.logout,
                          size: 14,
                          color: Color(0xFF054446),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // State 3: Membership Expired / Due -> Full-width "Check-in Pending" button
    if (isExpired) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _handleCheckIn(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF054446),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.login, size: 18),
          label: const Text(
            'Check-in Pending',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // State 4: Active member, not checked in yet today -> Solid Check-in + Outlined Check-out
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleCheckIn(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF054446),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.login, size: 18),
            label: const Text(
              'Check-in',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please check-in before checking out'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF344054),
              side: const BorderSide(color: Color(0xFFD0D5DD)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout, size: 18, color: Color(0xFF667085)),
            label: const Text(
              'Check-out',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF98A2B3),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF054446),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Member member, String planName) {
    if (member.profilePhotoPath != null &&
        member.profilePhotoPath!.isNotEmpty) {
      final file = File(member.profilePhotoPath!);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 22,
          backgroundImage: FileImage(file),
        );
      }
    }

    // Default pastel or teal initials circle
    Color bgColor;
    Color textColor;
    if (planName == 'ELITE') {
      bgColor = const Color(0xFF054446);
      textColor = Colors.white;
    } else if (planName == 'PREMIUM') {
      bgColor = const Color(0xFF99F6E4);
      textColor = const Color(0xFF0F766E);
    } else {
      bgColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF475467);
    }

    final initials = AppFormatters.getInitials(member.name);

    return CircleAvatar(
      radius: 22,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPlanBadge(String planName) {
    Color bg;
    Color text;

    if (planName == 'ELITE') {
      bg = const Color(0xFF00C853);
      text = Colors.white;
    } else if (planName == 'PREMIUM') {
      bg = const Color(0xFFE2E8F0);
      text = const Color(0xFF334155);
    } else {
      bg = const Color(0xFFF2F4F7);
      text = const Color(0xFF667085);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        planName,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: text,
        ),
      ),
    );
  }
}
