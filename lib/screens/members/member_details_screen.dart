import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../providers/member_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/full_screen_image_viewer.dart';
import 'edit_member_screen.dart';

class MemberDetailsScreen extends StatelessWidget {
  final Member member;

  const MemberDetailsScreen({super.key, required this.member});

  void _openEdit(BuildContext context, Member currentMember) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditMemberScreen(member: currentMember),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Member currentMember) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Member',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${currentMember.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (currentMember.id == null) return;
              final success = await context
                  .read<MemberProvider>()
                  .deleteMember(currentMember.id!);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Member deleted successfully'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep member data reactive to updates
    final membersList = context.watch<MemberProvider>().members;
    final currentMember = membersList.cast<Member?>().firstWhere(
          (m) => m?.id == member.id,
          orElse: () => member,
        ) ??
        member;

    // Plans and Trainers lookup
    final plans = context.watch<MemberProvider>().membershipPlans;
    final assignedPlan = currentMember.planId != null
        ? plans.cast().firstWhere(
            (p) => p.id == currentMember.planId,
            orElse: () => null,
          )
        : null;

    final trainers = context.watch<MemberProvider>().trainers;
    final assignedTrainer = currentMember.trainerId != null
        ? trainers.cast().firstWhere(
            (t) => t.id == currentMember.trainerId,
            orElse: () => null,
          )
        : null;

    final status = currentMember.getMembershipStatus(
      planDurationDays: assignedPlan?.durationDays ?? 30,
    );

    final planName = assignedPlan?.name.toUpperCase() ?? 'NORMAL';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF344054),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Member Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF054446),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.tealPrimary),
            tooltip: 'Edit Member',
            onPressed: () => _openEdit(context, currentMember),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF667085)),
            onSelected: (val) {
              if (val == 'delete') _confirmDelete(context, currentMember);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          children: [
            // ── HERO PROFILE CARD ──────────────────────────────────────────
            _buildHeroCard(currentMember, planName, status),

            const SizedBox(height: 16),

            // ── MEMBERSHIP & TRAINER SECTION ─────────────────────────────
            _buildMembershipCard(currentMember, assignedPlan, assignedTrainer, status),

            const SizedBox(height: 16),

            // ── HEALTH & FITNESS METRICS ─────────────────────────────────
            _buildHealthFitnessCard(currentMember),

            const SizedBox(height: 16),

            // ── PERSONAL DETAILS ─────────────────────────────────────────
            _buildPersonalDetailsCard(currentMember),

            const SizedBox(height: 16),

            // ── DOCUMENTS & ATTACHMENTS ──────────────────────────────────
            Builder(
              builder: (ctx) => _buildDocumentsCard(ctx, currentMember),
            ),
          ],
        ),
      ),
    );
  }

  // 1. HERO HEADER CARD
  Widget _buildHeroCard(Member member, String planName, MembershipStatus status) {
    final bool hasPhoto = member.profilePhotoPath != null &&
        File(member.profilePhotoPath!).existsSync();

    final bool isExpired = status.isExpired;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Photo / Avatar — tap to view full screen
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: hasPhoto
                  ? () => FullScreenImageViewer.show(
                        ctx,
                        imagePath: member.profilePhotoPath!,
                        title: member.name,
                        heroTag: 'member_photo_${member.id}',
                      )
                  : null,
              child: Hero(
                tag: 'member_photo_${member.id}',
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF054446),
                    border: Border.all(color: const Color(0xFFEAECF0), width: 3),
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.file(
                            File(member.profilePhotoPath!),
                            fit: BoxFit.cover,
                            width: 88,
                            height: 88,
                          )
                        : Center(
                            child: Text(
                              AppFormatters.getInitials(member.name),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          if (hasPhoto) ...
            [
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.zoom_in, size: 12, color: Color(0xFF98A2B3)),
                  SizedBox(width: 3),
                  Text(
                    'Tap photo to view',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ],
          const SizedBox(height: 14),

          // Name
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 6),

          // Plan & Status badges row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildBadge(
                label: planName,
                bgColor: _getPlanBadgeBg(planName),
                textColor: _getPlanBadgeFg(planName),
              ),
              _buildBadge(
                label: isExpired ? 'EXPIRED' : member.status.toUpperCase(),
                bgColor: isExpired
                    ? const Color(0xFFFEE4E2)
                    : const Color(0xFFD1FADF),
                textColor: isExpired
                    ? const Color(0xFFD92D20)
                    : const Color(0xFF027A48),
              ),
              _buildBadge(
                label: status.daysLeftText,
                bgColor: const Color(0xFFF2F4F7),
                textColor: const Color(0xFF344054),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. MEMBERSHIP & TRAINER CARD
  Widget _buildMembershipCard(
    Member member,
    dynamic assignedPlan,
    dynamic assignedTrainer,
    MembershipStatus status,
  ) {
    return _buildSectionCard(
      title: 'Membership & Trainer',
      icon: Icons.card_membership_outlined,
      children: [
        _buildInfoRow('Assigned Plan', assignedPlan?.name ?? 'Normal Plan'),
        _buildInfoRow('Plan Duration', '${assignedPlan?.durationDays ?? 30} Days'),
        _buildInfoRow('Validity Period', status.dateRangeText),
        _buildInfoRow('Personal Trainer', assignedTrainer?.name ?? 'Unassigned'),
        _buildInfoRow(
          'Preferred Workout Time',
          member.preferredTime?.isNotEmpty == true
              ? member.preferredTime!
              : 'Flexible',
        ),
      ],
    );
  }

  // 3. HEALTH & FITNESS CARD
  Widget _buildHealthFitnessCard(Member member) {
    return _buildSectionCard(
      title: 'Health & Fitness Profile',
      icon: Icons.fitness_center_outlined,
      children: [
        // 4-Card Quick Metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                'Height',
                member.height != null ? '${member.height!.toStringAsFixed(0)} cm' : '--',
                Icons.height,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                'Weight',
                member.weight != null ? '${member.weight!.toStringAsFixed(1)} kg' : '--',
                Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                'Target',
                member.targetWeight != null
                    ? '${member.targetWeight!.toStringAsFixed(1)} kg'
                    : '--',
                Icons.track_changes_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                'BMI',
                member.bmi != null ? member.bmi!.toStringAsFixed(1) : '--',
                Icons.speed,
                highlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildInfoRow('Fitness Goal', member.fitnessGoal ?? 'General Fitness'),
        _buildInfoRow('Activity Level', member.activityLevel ?? 'Moderate'),
        _buildInfoRow('Emotional Health', member.emotionalHealth ?? 'Good'),
        _buildInfoRow(
          'Medical Conditions',
          member.medicalConditions?.isNotEmpty == true
              ? member.medicalConditions!
              : 'None Reported',
        ),
      ],
    );
  }

  // 4. PERSONAL DETAILS CARD
  Widget _buildPersonalDetailsCard(Member member) {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow('Mobile Number', member.mobileNumber),
        _buildInfoRow(
          'Email Address',
          member.email?.isNotEmpty == true ? member.email! : 'Not provided',
        ),
        _buildInfoRow(
          'Date of Birth',
          member.dob?.isNotEmpty == true ? member.dob! : 'Not provided',
        ),
        _buildInfoRow('Gender', member.gender ?? 'Not specified'),
        _buildInfoRow('Blood Group', member.bloodGroup ?? 'Not specified'),
        _buildInfoRow(
          'Address',
          member.address?.isNotEmpty == true ? member.address! : 'Not provided',
        ),
      ],
    );
  }

  // 5. DOCUMENTS CARD
  Widget _buildDocumentsCard(BuildContext context, Member member) {
    final bool hasId = member.idProofPath != null &&
        File(member.idProofPath!).existsSync();
    final bool hasMedical = member.medicalReportsPath != null &&
        File(member.medicalReportsPath!).existsSync();

    return _buildSectionCard(
      title: 'Uploaded Documents',
      icon: Icons.folder_open_outlined,
      children: [
        _buildDocumentTile(
          context: context,
          title: 'ID Proof Document',
          hasFile: hasId,
          filePath: member.idProofPath,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 10),
        _buildDocumentTile(
          context: context,
          title: 'Medical Reports',
          hasFile: hasMedical,
          filePath: member.medicalReportsPath,
          icon: Icons.medical_services_outlined,
        ),
      ],
    );
  }

  // ── REUSABLE UI BUILDERS ──────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.tealPrimary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF2F4F7)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF667085),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.tealPrimary.withValues(alpha: 0.08)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? AppColors.tealPrimary.withValues(alpha: 0.25)
              : const Color(0xFFEAECF0),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: highlight ? AppColors.tealPrimary : const Color(0xFF667085),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.tealDark : const Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile({
    required BuildContext context,
    required String title,
    required bool hasFile,
    required String? filePath,
    required IconData icon,
  }) {
    final fileName = filePath != null ? filePath.split(Platform.pathSeparator).last : '';
    final ext = filePath != null ? filePath.split('.').last.toLowerCase() : '';
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);

    void openFile() {
      if (!hasFile || filePath == null) return;
      if (isImage) {
        FullScreenImageViewer.show(
          context,
          imagePath: filePath,
          title: title,
        );
      } else {
        OpenFile.open(filePath);
      }
    }

    return GestureDetector(
      onTap: hasFile ? openFile : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFF8FAFC) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? AppColors.tealPrimary.withValues(alpha: 0.2) : const Color(0xFFEAECF0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasFile ? AppColors.tealPrimary : const Color(0xFF98A2B3),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                    ),
                  ),
                  Text(
                    hasFile ? fileName : 'No file uploaded',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      color: hasFile ? const Color(0xFF667085) : const Color(0xFF98A2B3),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasFile) ...
              [
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: openFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.tealPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isImage ? Icons.image_outlined : Icons.open_in_new,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'View',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            else ...
              [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Missing',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _getPlanBadgeBg(String planName) {
    switch (planName) {
      case 'ELITE':
        return const Color(0xFF00E676).withValues(alpha: 0.15);
      case 'PREMIUM':
        return const Color(0xFFA4F4E7);
      case 'NORMAL':
      default:
        return const Color(0xFFEAECF0);
    }
  }

  Color _getPlanBadgeFg(String planName) {
    switch (planName) {
      case 'ELITE':
        return const Color(0xFF027A48);
      case 'PREMIUM':
        return const Color(0xFF054446);
      case 'NORMAL':
      default:
        return const Color(0xFF475467);
    }
  }
}
