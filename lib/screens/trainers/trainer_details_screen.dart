import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../models/trainer.dart';
import '../../providers/member_provider.dart';
import '../../providers/trainer_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../members/member_details_screen.dart';
import 'edit_trainer_screen.dart';

class TrainerDetailsScreen extends StatelessWidget {
  final Trainer trainer;

  const TrainerDetailsScreen({super.key, required this.trainer});

  void _openEdit(BuildContext context, Trainer currentTrainer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditTrainerScreen(trainer: currentTrainer),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Trainer currentTrainer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Trainer',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${currentTrainer.name}"? This action cannot be undone.',
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
              if (currentTrainer.id == null) return;
              final success = await context
                  .read<TrainerProvider>()
                  .deleteTrainer(currentTrainer.id!);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trainer deleted successfully'),
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
    // Keep trainer data reactive to updates
    final trainersList = context.watch<TrainerProvider>().trainers;
    final currentTrainer = trainersList.cast<Trainer?>().firstWhere(
          (t) => t?.id == trainer.id,
          orElse: () => trainer,
        ) ??
        trainer;

    // Get assigned members
    final allMembers = context.watch<MemberProvider>().members;
    final assignedMembers = currentTrainer.id != null
        ? allMembers.where((m) => m.trainerId == currentTrainer.id).toList()
        : <Member>[];

    final status = currentTrainer.salaryStatus;
    final bool isPaid = status.isPaid;

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
          'Trainer Profile',
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
            tooltip: 'Edit Trainer',
            onPressed: () => _openEdit(context, currentTrainer),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF667085)),
            onSelected: (val) {
              if (val == 'delete') _confirmDelete(context, currentTrainer);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          children: [
            // ── HERO PROFILE CARD ──────────────────────────────────────────
            _buildHeroCard(currentTrainer, isPaid),

            const SizedBox(height: 16),

            // ── QUICK METRICS ROW ────────────────────────────────────────
            _buildQuickMetricsRow(currentTrainer, assignedMembers.length),

            const SizedBox(height: 16),

            // ── EMPLOYMENT & SHIFT DETAILS ───────────────────────────────
            _buildEmploymentCard(currentTrainer, status),

            const SizedBox(height: 16),

            // ── ASSIGNED CLIENTS / TRAINEES ──────────────────────────────
            _buildAssignedMembersCard(context, assignedMembers),

            const SizedBox(height: 16),

            // ── PERSONAL DETAILS ─────────────────────────────────────────
            _buildPersonalDetailsCard(currentTrainer),

            const SizedBox(height: 16),

            // ── DOCUMENTS & CERTIFICATIONS ───────────────────────────────
            Builder(
              builder: (ctx) => _buildDocumentsCard(ctx, currentTrainer),
            ),
          ],
        ),
      ),
    );
  }

  // 1. HERO HEADER CARD
  Widget _buildHeroCard(Trainer trainer, bool isPaid) {
    final bool hasPhoto = trainer.profilePhotoPath != null &&
        File(trainer.profilePhotoPath!).existsSync();

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
                        imagePath: trainer.profilePhotoPath!,
                        title: trainer.name,
                        heroTag: 'trainer_photo_${trainer.id}',
                      )
                  : null,
              child: Hero(
                tag: 'trainer_photo_${trainer.id}',
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
                            File(trainer.profilePhotoPath!),
                            fit: BoxFit.cover,
                            width: 88,
                            height: 88,
                          )
                        : Center(
                            child: Text(
                              AppFormatters.getInitials(trainer.name),
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
          if (hasPhoto) ...[
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
            trainer.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 6),

          // Badges row: Qualification + Salary Status + Experience
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildBadge(
                label: trainer.qualification?.isNotEmpty == true
                    ? trainer.qualification!.toUpperCase()
                    : 'FITNESS TRAINER',
                bgColor: const Color(0xFFE0F2FE),
                textColor: const Color(0xFF0369A1),
              ),
              _buildBadge(
                label: isPaid ? 'SALARY PAID' : 'SALARY DUE',
                bgColor: isPaid
                    ? const Color(0xFFD1FADF)
                    : const Color(0xFFFEE4E2),
                textColor: isPaid
                    ? const Color(0xFF027A48)
                    : const Color(0xFFD92D20),
              ),
              if (trainer.experience?.isNotEmpty == true)
                _buildBadge(
                  label: '${trainer.experience} Exp',
                  bgColor: const Color(0xFFF2F4F7),
                  textColor: const Color(0xFF344054),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. QUICK METRICS ROW
  Widget _buildQuickMetricsRow(Trainer trainer, int assignedCount) {
    final shiftText = (trainer.shiftStart?.isNotEmpty == true && trainer.shiftEnd?.isNotEmpty == true)
        ? '${trainer.shiftStart} - ${trainer.shiftEnd}'
        : 'Flexible';

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            'Salary',
            '₹${AppFormatters.formatAmount(trainer.salary)}',
            Icons.currency_rupee_rounded,
            highlight: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            'Trainees',
            '$assignedCount Active',
            Icons.groups_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            'Age',
            '${trainer.age} Yrs',
            Icons.cake_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            'Shift',
            shiftText,
            Icons.schedule_outlined,
          ),
        ),
      ],
    );
  }

  // 3. EMPLOYMENT & SHIFT DETAILS CARD
  Widget _buildEmploymentCard(
    Trainer trainer,
    ({bool isPaid, DateTime nextPaymentDate}) status,
  ) {
    final String nextDateStr = AppFormatters.formatDisplayDate(
      status.nextPaymentDate,
      dayFirst: true,
    );

    String joiningDateStr = trainer.joiningDate;
    final parsedJoining = AppFormatters.parseDate(trainer.joiningDate);
    if (parsedJoining != null) {
      joiningDateStr = AppFormatters.formatDisplayDate(parsedJoining, dayFirst: true);
    }

    final shiftTimings = (trainer.shiftStart?.isNotEmpty == true || trainer.shiftEnd?.isNotEmpty == true)
        ? '${trainer.shiftStart ?? '--'} to ${trainer.shiftEnd ?? '--'}'
        : 'Flexible / Not scheduled';

    return _buildSectionCard(
      title: 'Employment & Compensation',
      icon: Icons.work_outline_rounded,
      children: [
        _buildInfoRow(
          'Monthly Salary',
          '₹${AppFormatters.formatAmount(trainer.salary, decimals: 2)}',
        ),
        _buildInfoRow(
          'Salary Status',
          status.isPaid ? 'Paid' : 'Due for Payment',
        ),
        _buildInfoRow(
          status.isPaid ? 'Next Pay Date' : 'Payment Due Date',
          nextDateStr,
        ),
        _buildInfoRow('Shift Hours', shiftTimings),
        _buildInfoRow('Joining Date', joiningDateStr),
        _buildInfoRow(
          'Experience',
          trainer.experience?.isNotEmpty == true ? trainer.experience! : 'Not specified',
        ),
        _buildInfoRow(
          'Qualification',
          trainer.qualification?.isNotEmpty == true ? trainer.qualification! : 'Not specified',
        ),
      ],
    );
  }

  // 4. ASSIGNED CLIENTS / TRAINEES CARD
  Widget _buildAssignedMembersCard(BuildContext context, List<Member> members) {
    return _buildSectionCard(
      title: 'Assigned Trainees (${members.length})',
      icon: Icons.sports_gymnastics_rounded,
      children: [
        if (members.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Color(0xFF98A2B3)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No members currently assigned to this trainer.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: members.map((m) {
              final bool hasMemberPhoto = m.profilePhotoPath != null &&
                  File(m.profilePhotoPath!).existsSync();

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF054446),
                    backgroundImage: hasMemberPhoto
                        ? FileImage(File(m.profilePhotoPath!))
                        : null,
                    child: hasMemberPhoto
                        ? null
                        : Text(
                            AppFormatters.getInitials(m.name),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  title: Text(
                    m.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                    ),
                  ),
                  subtitle: Text(
                    m.mobileNumber,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF98A2B3),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MemberDetailsScreen(member: m),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // 5. PERSONAL DETAILS CARD
  Widget _buildPersonalDetailsCard(Trainer trainer) {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow(
          'Mobile Number',
          trainer.mobileNumber?.isNotEmpty == true ? trainer.mobileNumber! : 'Not provided',
        ),
        _buildInfoRow(
          'Email Address',
          trainer.email?.isNotEmpty == true ? trainer.email! : 'Not provided',
        ),
        _buildInfoRow('Age', '${trainer.age} Years'),
        _buildInfoRow(
          'Date of Birth',
          trainer.dob?.isNotEmpty == true ? trainer.dob! : 'Not provided',
        ),
        _buildInfoRow('Gender', trainer.gender ?? 'Not specified'),
        _buildInfoRow('Blood Group', trainer.bloodGroup ?? 'Not specified'),
        _buildInfoRow(
          'Address',
          trainer.address?.isNotEmpty == true ? trainer.address! : 'Not provided',
        ),
      ],
    );
  }

  // 6. DOCUMENTS CARD
  Widget _buildDocumentsCard(BuildContext context, Trainer trainer) {
    final bool hasId = trainer.idProofPath != null &&
        File(trainer.idProofPath!).existsSync();
    final bool hasCert = trainer.certificatePhotoPath != null &&
        File(trainer.certificatePhotoPath!).existsSync();

    return _buildSectionCard(
      title: 'Uploaded Documents',
      icon: Icons.folder_open_outlined,
      children: [
        _buildDocumentTile(
          context: context,
          title: 'ID Proof Document',
          hasFile: hasId,
          filePath: trainer.idProofPath,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 10),
        _buildDocumentTile(
          context: context,
          title: 'Certificate / Qualification Proof',
          hasFile: hasCert,
          filePath: trainer.certificatePhotoPath,
          icon: Icons.workspace_premium_outlined,
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
            if (hasFile) ...[
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
            ] else ...[
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
}
