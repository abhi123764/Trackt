import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/member_provider.dart';
import 'widgets/attendance_card.dart';
import 'widgets/attendance_filter_sheet.dart';
import 'widgets/attendance_sort_sheet.dart';
import 'widgets/mark_attendance_sheet.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchAttendanceData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.read<DashboardProvider>().setTab(0);
    }
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AttendanceSortSheet(),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AttendanceFilterSheet(),
    );
  }

  void _openMarkAttendanceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MarkAttendanceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<AttendanceProvider>(
          builder: (context, provider, child) {
            final items = provider.filteredItems;

            return Column(
              children: [
                _buildHeader(context),
                _buildSearchAndControlRow(provider),
                _buildPlanFilterChips(provider),
                const SizedBox(height: 8),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF054446),
                          ),
                        )
                      : provider.errorMessage != null
                      ? _buildErrorState(provider)
                      : items.isEmpty
                      ? _buildEmptyState(provider)
                      : RefreshIndicator(
                          color: const Color(0xFF054446),
                          onRefresh: () async {
                            await provider.fetchAttendanceData();
                            if (context.mounted) {
                              await context.read<MemberProvider>().fetchMembers();
                            }
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return AttendanceCard(item: item);
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openMarkAttendanceSheet,
        backgroundColor: const Color(0xFF054446),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // 1. TOP HEADER (Back button, Attendance Details title, bell icon, user avatar)
  Widget _buildHeader(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final initial = currentUser?.initial ?? 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          InkWell(
            onTap: _navigateBack,
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
          const Expanded(
            child: Text(
              'Attendance Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF054446),
              ),
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
    );
  }

  // 2. SEARCH & DUAL ACTION BUTTONS ROW (Search bar + Sort button + Filter button)
  Widget _buildSearchAndControlRow(AttendanceProvider provider) {
    final bool isSorted = provider.isSorted;
    final bool isFiltered = provider.hasActiveFilters;

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
  Widget _buildPlanFilterChips(AttendanceProvider provider) {
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

          // Plan chips (Elite, Premium, Normal)
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

  Widget _buildEmptyState(AttendanceProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                size: 48,
                color: Color(0xFF98A2B3),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Members Found',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing your search query or reset your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF667085),
              ),
            ),
            if (provider.hasActiveFilters || provider.isSorted) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  provider.resetFilters();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF054446)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset Filters',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF054446),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AttendanceProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFD92D20)),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF475467),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchAttendanceData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF054446),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
