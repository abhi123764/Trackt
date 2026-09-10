import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trainer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trainer_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../dashboard/dashboard_screen.dart';
import 'add_trainer_screen.dart';
import 'edit_trainer_screen.dart';
import 'trainer_details_screen.dart';
import 'widgets/trainer_card.dart';

class TrainersScreen extends StatefulWidget {
  const TrainersScreen({super.key});

  @override
  State<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends State<TrainersScreen> {
  final _searchController = TextEditingController();

  void _navigateBackToDashboard() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainerProvider>().fetchTrainers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddTrainer() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddTrainerScreen()))
        .then((_) {
          if (!mounted) return;
          context.read<TrainerProvider>().fetchTrainers();
        });
  }

  void _openEditTrainer(Trainer trainer) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => EditTrainerScreen(trainer: trainer),
          ),
        )
        .then((_) {
          if (!mounted) return;
          context.read<TrainerProvider>().fetchTrainers();
        });
  }

  void _openTrainerDetails(Trainer trainer) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => TrainerDetailsScreen(trainer: trainer),
          ),
        )
        .then((_) {
          if (!mounted) return;
          context.read<TrainerProvider>().fetchTrainers();
        });
  }

  void _confirmDelete(Trainer trainer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Trainer',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${trainer.name}"? This action cannot be undone.',
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
              if (trainer.id == null) return;
              final success = await context
                  .read<TrainerProvider>()
                  .deleteTrainer(trainer.id!);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trainer deleted successfully'),
                    backgroundColor: AppColors.danger,
                  ),
                );
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
    final currentUser = context.watch<AuthProvider>().currentUser;
    final initial = currentUser?.initial ?? 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<TrainerProvider>(
          builder: (context, provider, _) {
            final trainers = provider.filteredTrainers;
            final double totalPayouts = provider.totalPayouts;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TOP HEADER ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _navigateBackToDashboard,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF344054),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'MANAGEMENT',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: Color(0xFF98A2B3),
                              ),
                            ),
                            Text(
                              'Trainers',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF054446),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none_outlined,
                          color: Color(0xFF344054),
                          size: 24,
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF054446),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── SEARCH BAR ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: provider.setSearchQuery,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Search by name or specialty...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          color: Color(0xFF98A2B3),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF667085),
                          size: 20,
                        ),
                        suffixIcon: provider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 18,
                                  color: Color(0xFF667085),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearchQuery('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── STATUS FILTER CHIPS ROW ────────────────────────────
                _buildStatusFilterChips(provider),

                const SizedBox(height: 8),

                // ── TRAINER CARDS LIST ─────────────────────────────────
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.tealPrimary,
                          ),
                        )
                      : provider.errorMessage != null
                      ? _buildErrorState(provider)
                      : trainers.isEmpty
                      ? _buildEmptyState(provider)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          itemCount: trainers.length,
                          itemBuilder: (_, i) => TrainerCard(
                            trainer: trainers[i],
                            onTap: () => _openTrainerDetails(trainers[i]),
                            onEdit: () => _openEditTrainer(trainers[i]),
                            onDelete: () => _confirmDelete(trainers[i]),
                          ),
                        ),
                ),

                // ── SUMMARY STATS ROW ──────────────────────────────────
                if (!provider.isLoading && provider.errorMessage == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.trending_up_rounded,
                            iconColor: AppColors.tealPrimary,
                            label: 'Total Payouts',
                            value:
                                '₹${AppFormatters.formatAmount(totalPayouts)}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.verified_outlined,
                            iconColor: AppColors.accentGreen,
                            label: 'Active Staff',
                            value: '${provider.trainers.length} Members',
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 76),
              ],
            );
          },
        ),
      ),

      // ── FAB: Add Trainer ─────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTrainer,
        backgroundColor: const Color(0xFF054446),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
        label: const Text(
          'Add Trainer',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF98A2B3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101828),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTER CHIPS ROW ─────────────────────────────────────────────────────
  Widget _buildStatusFilterChips(TrainerProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All Trainers',
            isSelected: provider.statusFilter == 'all',
            onTap: () => provider.setStatusFilter('all'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Salary Paid',
            isSelected: provider.statusFilter == 'paid',
            onTap: () => provider.setStatusFilter('paid'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Salary Due',
            isSelected: provider.statusFilter == 'due',
            onTap: () => provider.setStatusFilter('due'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF054446) : const Color(0xFFEAECF0),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475467),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(TrainerProvider provider) {
    final bool isFiltered = provider.searchQuery.isNotEmpty || provider.statusFilter != 'all';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltered ? Icons.filter_alt_off_outlined : Icons.sports_gymnastics,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No Matching Trainers' : 'No Trainers Yet',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try adjusting your search query or status filter.'
                  : 'Tap "Add Trainer" below to register your first trainer.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF667085),
              ),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                  provider.setStatusFilter('all');
                },
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('Reset Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(TrainerProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.fetchTrainers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
