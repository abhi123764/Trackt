import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_provider.dart';
import '../../theme/app_theme.dart';
import 'add_member_screen.dart';
import 'edit_member_screen.dart';
import 'widgets/member_card.dart';
import 'widgets/member_filter_sheet.dart';
import 'widgets/member_sort_sheet.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().fetchMembers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddMemberDialog() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddMemberScreen()));
  }

  void _openEditMemberDialog(Member member) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditMemberScreen(member: member)));
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MemberSortSheet(),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MemberFilterSheet(),
    );
  }

  void _confirmDelete(Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Member',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${member.name}"? This action cannot be undone.',
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
              final success = await context.read<MemberProvider>().deleteMember(
                member.id!,
              );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Member deleted successfully'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<MemberProvider>(
          builder: (context, provider, child) {
            final membersList = provider.filteredMembers;

            return Column(
              children: [
                _buildHeader(context),
                _buildSearchAndControlRow(provider),
                _buildPlanFilterChips(provider),
                const SizedBox(height: 8),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.errorMessage != null
                      ? _buildErrorState(provider)
                      : membersList.isEmpty
                      ? _buildEmptyState(provider)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                          itemCount: membersList.length,
                          itemBuilder: (context, index) {
                            final member = membersList[index];
                            return MemberCard(
                              member: member,
                              onEdit: () => _openEditMemberDialog(member),
                              onDelete: () => _confirmDelete(member),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMemberDialog,
        backgroundColor: const Color(0xFF054446),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // 1. TOP HEADER (Members title, bell icon, user avatar)
  Widget _buildHeader(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final initial = (currentUser != null && currentUser.fName.isNotEmpty)
        ? currentUser.fName[0].toUpperCase()
        : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Members',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF054446),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF344054),
                  size: 24,
                ),
              ),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF054446),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. SEARCH & DUAL ACTION BUTTONS ROW (Search bar + Sort button + Filter button)
  Widget _buildSearchAndControlRow(MemberProvider provider) {
    final bool isSorted = provider.sortOption != MemberSortOption.nameAsc;
    final bool isFiltered =
        provider.statusFilter != 'All' ||
        provider.genderFilter != 'All' ||
        provider.planFilter != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          // Search Field
          Expanded(
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
                  hintText: 'Search members...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF98A2B3),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF667085),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
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
          const SizedBox(width: 8),

          // Dedicated Sort Button
          InkWell(
            onTap: _openSortSheet,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSorted
                    ? const Color(0xFF054446)
                    : const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSorted
                      ? const Color(0xFF054446)
                      : const Color(0xFFEAECF0),
                ),
              ),
              child: Icon(
                Icons.sort_rounded,
                color: isSorted ? Colors.white : const Color(0xFF344054),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Dedicated Filter Button
          InkWell(
            onTap: _openFilterSheet,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isFiltered
                    ? const Color(0xFF054446)
                    : const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFiltered
                      ? const Color(0xFF054446)
                      : const Color(0xFFEAECF0),
                ),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: isFiltered ? Colors.white : const Color(0xFF344054),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. HORIZONTAL MEMBERSHIP PLAN CHIPS ROW (All, Elite, Premium, Normal)
  Widget _buildPlanFilterChips(MemberProvider provider) {
    final plans = provider.membershipPlans;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          // "All" chip
          _buildPlanChip(
            label: 'All',
            isSelected: provider.planFilter == null,
            onTap: () => provider.setPlanFilter(null),
          ),
          const SizedBox(width: 8),

          // Dynamic plan chips (Elite, Premium, Normal)
          ...plans.map((plan) {
            final isSelected = provider.planFilter == plan.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildPlanChip(
                label: plan.name,
                isSelected: isSelected,
                onTap: () =>
                    provider.setPlanFilter(isSelected ? null : plan.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlanChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF054446) : const Color(0xFFEAECF0),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475467),
          ),
        ),
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState(MemberProvider provider) {
    final isSearching =
        provider.searchQuery.isNotEmpty || provider.hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.filter_alt_off : Icons.group_outlined,
              size: 60,
              color: const Color(0xFF98A2B3),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'No members match your filter criteria'
                  : 'No Members Added Yet',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try adjusting your search query, status, gender, or plan filters.'
                  : 'Tap "+" below to add your first member.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF667085),
              ),
            ),
            if (isSearching) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: provider.resetFilters,
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('Reset Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ERROR STATE
  Widget _buildErrorState(MemberProvider provider) {
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
              onPressed: provider.fetchMembers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
