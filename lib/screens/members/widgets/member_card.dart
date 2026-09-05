import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/member.dart';
import '../../../providers/member_provider.dart';
import '../../../theme/app_theme.dart';

class MemberCard extends StatefulWidget {
  final Member member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MemberCard({
    super.key,
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _handleCheckIn() async {
    if (widget.member.id == null) return;
    final timeStr = _formatCurrentTime();
    final provider = context.read<MemberProvider>();
    final success = await provider.checkInMember(widget.member.id!, timeStr);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checked in ${widget.member.name} at $timeStr'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.tealPrimary,
        ),
      );
    }
  }

  Future<void> _handleCheckOut() async {
    if (widget.member.id == null) return;
    final timeStr = _formatCurrentTime();
    final provider = context.read<MemberProvider>();
    final success = await provider.checkOutMember(widget.member.id!, timeStr);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checked out ${widget.member.name} at $timeStr'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.tealPrimary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;

    // Get today's attendance from provider
    final todayAttendance = member.id != null
        ? context.watch<MemberProvider>().getTodayAttendance(member.id!)
        : null;

    final bool isCheckedIn =
        todayAttendance != null &&
        todayAttendance.checkIn != null &&
        todayAttendance.checkOut == null;

    final String? checkInTime = todayAttendance?.checkIn;
    final String? checkOutTime = todayAttendance?.checkOut;

    // Get assigned plan
    final membershipPlans = context.watch<MemberProvider>().membershipPlans;
    final assignedPlan = member.planId != null
        ? membershipPlans.cast().firstWhere(
            (p) => p.id == member.planId,
            orElse: () => null,
          )
        : null;

    final planName = assignedPlan?.name.toUpperCase() ?? 'NORMAL';

    // Get assigned trainer
    final trainers = context.watch<MemberProvider>().trainers;
    final assignedTrainer = member.trainerId != null
        ? trainers.cast().firstWhere(
            (t) => t.id == member.trainerId,
            orElse: () => null,
          )
        : null;
    final String trainerName = assignedTrainer?.name ?? 'Unassigned';

    // Calculate dynamic dates and days left
    DateTime startDate;
    try {
      startDate = DateTime.parse(member.joinDate);
    } catch (_) {
      startDate = DateTime.now();
    }
    final int duration = assignedPlan?.durationDays ?? 30;
    final DateTime endDate = startDate.add(Duration(days: duration));
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime endDay = DateTime(endDate.year, endDate.month, endDate.day);
    final int daysLeft = endDay.difference(today).inDays;

    final bool isExpired =
        member.status.toLowerCase() == 'inactive' ||
        member.status.toLowerCase() == 'expired' ||
        daysLeft < 0;

    final String daysLeftText = isExpired
        ? 'Expired'
        : daysLeft == 0
        ? 'Expires Today'
        : '$daysLeft Days Left';

    final String dateRangeText =
        '${_formatDate(startDate)} - ${_formatDate(endDate)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
            // 1. TOP HEADER ROW (Avatar, Name, Plan Badge, Trainer, Edit/Delete)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _getAvatarBg(planName),
                  child: Text(
                    _getInitials(member.name),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _getAvatarTextColor(planName),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Plan & Trainer
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
                      const SizedBox(height: 2),
                      Text(
                        'Trainer: $trainerName',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit Pencil Button
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Color(0xFF667085),
                  ),
                  onPressed: widget.onEdit,
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Color(0xFF667085),
                  ),
                  onSelected: (val) {
                    if (val == 'delete') widget.onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: AppColors.danger,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete Member',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF2F4F7)),
            const SizedBox(height: 14),

            // 2. MEMBERSHIP SECTION (Status, Date range, Due/Paid badge, Renew link)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 2),
                    Text(
                      dateRangeText,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Payment Status Pill
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
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Renewing membership for ${member.name}',
                            ),
                            backgroundColor: AppColors.tealPrimary,
                          ),
                        );
                      },
                      child: Text(
                        'Renew',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isExpired
                              ? const Color(0xFFD92D20)
                              : const Color(0xFF054446),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. ATTENDANCE SECTION
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
                Text(
                  isCheckedIn
                      ? 'Status: Checked-in at $checkInTime'
                      : checkOutTime != null
                      ? 'Status: Checked-out at $checkOutTime'
                      : isExpired
                      ? 'Last check-in: Expired'
                      : 'Status: Not Checked-in Today',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Check-in / Check-out Buttons or IN / OUT Time boxes
            if (isCheckedIn)
              Row(
                children: [
                  Expanded(child: _buildTimeBox('IN', checkInTime ?? 'Active')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleCheckOut,
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(
                        'Check-out',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (checkInTime != null && checkOutTime != null)
              Row(
                children: [
                  Expanded(child: _buildTimeBox('IN', checkInTime)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimeBox('OUT', checkOutTime)),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF054446),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleCheckIn,
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text(
                        'Check-in',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF054446),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanBadge(String planName) {
    Color bg;
    Color fg;

    switch (planName) {
      case 'ELITE':
        bg = const Color(0xFF00E676);
        fg = Colors.white;
        break;
      case 'PREMIUM':
        bg = const Color(0xFFE4E7EC);
        fg = const Color(0xFF344054);
        break;
      case 'NORMAL':
      default:
        bg = const Color(0xFFEAECF0);
        fg = const Color(0xFF475467);
        break;
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
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color _getAvatarBg(String planName) {
    switch (planName) {
      case 'ELITE':
        return const Color(0xFF054446);
      case 'PREMIUM':
        return const Color(0xFFA4F4E7);
      case 'NORMAL':
      default:
        return const Color(0xFFEAECF0);
    }
  }

  Color _getAvatarTextColor(String planName) {
    switch (planName) {
      case 'ELITE':
        return Colors.white;
      case 'PREMIUM':
        return const Color(0xFF054446);
      case 'NORMAL':
      default:
        return const Color(0xFF344054);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }
}
