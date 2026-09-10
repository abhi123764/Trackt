import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/payment_provider.dart';
import '../../utils/formatters.dart';
import '../expenses/expenses_screen.dart';
import '../expenses/widgets/add_expense_sheet.dart';
import '../../providers/expense_provider.dart';
import 'widgets/add_payment_sheet.dart';
import 'widgets/payment_filter_sheet.dart';

class PaymentsScreen extends StatefulWidget {
  final int initialSection;

  const PaymentsScreen({
    super.key,
    this.initialSection = 0,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late int _selectedSection;

  @override
  void initState() {
    super.initState();
    _selectedSection = widget.initialSection;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchPayments();
      context.read<ExpenseProvider>().fetchExpenses();
      // Ensure members and plans are loaded for selection
      if (context.read<MemberProvider>().members.isEmpty) {
        context.read<MemberProvider>().fetchMembers();
      }
    });
  }

  void _navigateBackToDashboard() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.read<DashboardProvider>().setTab(0);
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaymentFilterSheet(),
    );
  }

  void _openAddPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPaymentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final initial = currentUser?.initial ?? 'U';

    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<DashboardProvider>().setTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Consumer<PaymentProvider>(
            builder: (context, provider, _) {
              final payments = provider.filteredPayments;

              return RefreshIndicator(
                color: const Color(0xFF054446),
                onRefresh: () async {
                  await provider.fetchPayments();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                  children: [
                    // ── 1. TOP BAR ─────────────────────────────────────────────
                    Row(
                      children: [
                        // Back button
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
                        const Expanded(
                          child: Text(
                            'Payments',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── 1b. REVENUE VS EXPENSES TOGGLE ──────────────────────────
                    _buildSectionToggle(),

                    if (_selectedSection == 1) ...[
                      const ExpensesScreen(isEmbedded: true),
                    ] else ...[
                      const SizedBox(height: 16),

                      // ── 2. METRIC CARDS ROW ────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              label: 'COLLECTED TODAY',
                              value: '₹${AppFormatters.formatAmount(provider.collectedToday)}',
                              accentColor: const Color(0xFF054446),
                              footerWidget: Row(
                                children: [
                                  const Icon(
                                    Icons.trending_up_rounded,
                                    size: 14,
                                    color: Color(0xFF027A48),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      provider.todayTrendPercent >= 0
                                          ? '${provider.todayTrendPercent.toStringAsFixed(0)}% vs yest.'
                                          : '${provider.todayTrendPercent.abs().toStringAsFixed(0)}% vs yest.',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF027A48),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMetricCard(
                              label: 'PENDING',
                              value: '₹${AppFormatters.formatAmount(provider.pendingAmount)}',
                              accentColor: const Color(0xFFD92D20),
                              footerWidget: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE4E2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 11,
                                      color: Color(0xFFD92D20),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${provider.pendingCount} invoices',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD92D20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── 3. REVENUE THIS MONTH CARD ─────────────────────────────
                      _buildRevenueMonthCard(provider),

                      const SizedBox(height: 18),

                      // ── 4. ACTION TABS + FILTER BUTTON ROW ─────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _buildFilterButton(
                                  label: 'Pending Payments',
                                  icon: Icons.receipt_long_rounded,
                                  isActive: provider.activeTab == 'pending',
                                  onTap: () => provider.setActiveTab('pending'),
                                ),
                                const SizedBox(width: 8),
                                _buildFilterButton(
                                  label: 'Payment History',
                                  icon: Icons.history_rounded,
                                  isActive: provider.activeTab == 'all',
                                  onTap: () => provider.setActiveTab('all'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Filter icon button with badge
                          _buildFilterIconButton(provider),
                        ],
                      ),

                      // ── 4b. ACTIVE FILTER CHIPS ────────────────────────────────
                      if (provider.hasActiveFilters) ...[
                        const SizedBox(height: 12),
                        _buildActiveFilterChips(provider),
                      ],

                      const SizedBox(height: 22),

                      // ── 5. RECENT PAYMENTS HEADER ──────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.activeTab == 'pending'
                                    ? 'Pending Invoices'
                                    : 'Recent Payments',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828),
                                ),
                              ),
                              if (provider.hasActiveFilters)
                                Text(
                                  '${payments.length} result${payments.length == 1 ? '' : 's'} found',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.5,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                            ],
                          ),
                          InkWell(
                            onTap: () => provider.resetFilters(),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF054446),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── 6. RECENT PAYMENTS LIST ────────────────────────────────
                      if (provider.isLoading && payments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF054446)),
                          ),
                        )
                      else if (payments.isEmpty)
                        _buildEmptyState(provider.activeTab)
                      else
                        ...payments.map((p) => _buildPaymentTile(p)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // ── 7. FLOATING ACTION BUTTON ────────────────────────────────────
        floatingActionButton: _selectedSection == 0
            ? FloatingActionButton.extended(
                onPressed: _openAddPaymentSheet,
                backgroundColor: const Color(0xFF054446),
                elevation: 4,
                icon: const Icon(Icons.add_card, color: Colors.white, size: 20),
                label: const Text(
                  'Add Payment Details',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              )
            : FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddExpenseSheet(),
                  );
                },
                backgroundColor: const Color(0xFF054446),
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // ── REVENUE VS EXPENSES SECTION TOGGLE ────────────────────────────────────
  Widget _buildSectionToggle() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedSection = 0),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedSection == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedSection == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Revenue',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: _selectedSection == 0 ? FontWeight.w700 : FontWeight.w500,
                    color: _selectedSection == 0 ? const Color(0xFF054446) : const Color(0xFF667085),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedSection = 1),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedSection == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedSection == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Expenses',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: _selectedSection == 1 ? FontWeight.w700 : FontWeight.w500,
                    color: _selectedSection == 1 ? const Color(0xFF054446) : const Color(0xFF667085),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTER ICON BUTTON (with badge) ──────────────────────────────────────
  Widget _buildFilterIconButton(PaymentProvider provider) {
    final count = provider.activeFilterCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: _openFilterSheet,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: provider.hasActiveFilters
                  ? const Color(0xFF054446)
                  : const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: provider.hasActiveFilters
                    ? const Color(0xFF054446)
                    : const Color(0xFFEAECF0),
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: provider.hasActiveFilters
                  ? Colors.white
                  : const Color(0xFF344054),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF12B76A),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── ACTIVE FILTER CHIPS ROW ───────────────────────────────────────────────
  Widget _buildActiveFilterChips(PaymentProvider provider) {
    final chips = <Widget>[];

    if (provider.planFilter != null) {
      chips.add(_activeChip(
        label: '📋 ${provider.planFilter}',
        onRemove: () => provider.setPlanFilter(null),
      ));
    }

    if (provider.dateFilter != 'All') {
      String label = provider.dateFilter;
      if (label == 'Custom' &&
          provider.customFromDate != null &&
          provider.customToDate != null) {
        final f = provider.customFromDate!;
        final t = provider.customToDate!;
        final fmt =
            '${f.day}/${f.month} – ${t.day}/${t.month}/${t.year}';
        label = '📅 $fmt';
      } else {
        label = '📅 $label';
      }
      chips.add(_activeChip(
        label: label,
        onRemove: () => provider.setDateFilter('All'),
      ));
    }

    if (provider.methodFilter != null) {
      chips.add(_activeChip(
        label: '💳 ${provider.methodFilter}',
        onRemove: () => provider.setMethodFilter(null),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...chips,
          if (chips.length > 1)
            _activeChip(
              label: 'Clear all',
              onRemove: provider.resetFilters,
              isReset: true,
            ),
        ],
      ),
    );
  }

  Widget _activeChip({
    required String label,
    required VoidCallback onRemove,
    bool isReset = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isReset
            ? const Color(0xFFFFF1F0)
            : const Color(0xFFEFFAF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isReset
              ? const Color(0xFFFFCCC7)
              : const Color(0xFF6CE9A6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isReset
                  ? const Color(0xFFD92D20)
                  : const Color(0xFF027A48),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 13,
              color: isReset
                  ? const Color(0xFFD92D20)
                  : const Color(0xFF027A48),
            ),
          ),
        ],
      ),
    );
  }

  // ── METRIC CARD (COLLECTED TODAY / PENDING) ───────────────────────────────
  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color accentColor,
    required Widget footerWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored vertical left accent bar
              Container(width: 4, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: Color(0xFF667085),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101828),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      footerWidget,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── REVENUE THIS MONTH CARD ───────────────────────────────────────────────
  Widget _buildRevenueMonthCard(PaymentProvider provider) {
    final double percent = provider.monthlyGoalPercent;

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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with label and Goal Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'REVENUE THIS MONTH',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Color(0xFF667085),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Goal: ₹6L',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF054446),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Big Amount
          Text(
            '₹${AppFormatters.formatAmount(provider.monthlyRevenue)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 9,
              backgroundColor: const Color(0xFFE9ECEF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF054446)),
            ),
          ),
          const SizedBox(height: 8),

          // Target Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percent.toStringAsFixed(0)}% of monthly target',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF667085),
                ),
              ),
              Text(
                '₹${AppFormatters.formatAmount(provider.monthlyRemaining)} to go',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0369A1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── FILTER PILL BUTTON ───────────────────────────────────────────────────
  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF101828) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFF101828) : const Color(0xFFEAECF0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF344054),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF344054),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PAYMENT TILE ─────────────────────────────────────────────────────────
  Widget _buildPaymentTile(Map<String, dynamic> item) {
    final String memberName = item['member_name'] ?? 'Member #${item['member_id'] ?? '--'}';
    final String? memberPhoto = item['member_photo'];
    final bool hasPhoto = memberPhoto != null && File(memberPhoto).existsSync();
    final double amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
    final String planName = (item['plan_name'] as String? ?? 'NORMAL').toUpperCase();
    final String method = item['payment_method'] ?? 'Cash';
    final String dateStr = item['payment_date'] ?? '';

    // Relative date/time formatted
    String formattedTime = dateStr;
    final parsed = AppFormatters.parseDate(dateStr);
    if (parsed != null) {
      final now = DateTime.now();
      if (parsed.year == now.year && parsed.month == now.month && parsed.day == now.day) {
        formattedTime = 'Today';
      } else if (parsed.year == now.year && parsed.month == now.month && parsed.day == now.day - 1) {
        formattedTime = 'Yesterday';
      } else {
        formattedTime = AppFormatters.formatDisplayDate(parsed, dayFirst: true);
      }
    }

    final durationDays = item['plan_duration'] as int?;
    final durationText = durationDays != null
        ? (durationDays >= 365
            ? 'Annual Plan'
            : durationDays >= 90
                ? '3 Months'
                : 'Monthly')
        : 'General Plan';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: _getAvatarBg(planName),
            backgroundImage: hasPhoto ? FileImage(File(memberPhoto)) : null,
            child: hasPhoto
                ? null
                : Text(
                    AppFormatters.getInitials(memberName),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _getAvatarFg(planName),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Member Name, Plan Badge, Plan Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        memberName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101828),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildPlanBadge(planName),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$durationText • $method',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Right side: Amount and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${AppFormatters.formatAmount(amount)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedTime,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Color(0xFF98A2B3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
        bg = const Color(0xFF00E5FF);
        fg = const Color(0xFF054446);
        break;
      case 'PREMIUM':
        bg = const Color(0xFFEAECF0);
        fg = const Color(0xFF344054);
        break;
      case 'NORMAL':
      default:
        bg = const Color(0xFFF2F4F7);
        fg = const Color(0xFF667085);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        planName,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getAvatarBg(String planName) {
    switch (planName) {
      case 'ELITE':
        return const Color(0xFF00E5FF).withValues(alpha: 0.25);
      case 'PREMIUM':
        return const Color(0xFFEAECF0);
      case 'NORMAL':
      default:
        return const Color(0xFFF2F4F7);
    }
  }

  Color _getAvatarFg(String planName) {
    switch (planName) {
      case 'ELITE':
        return const Color(0xFF054446);
      case 'PREMIUM':
        return const Color(0xFF344054);
      case 'NORMAL':
      default:
        return const Color(0xFF667085);
    }
  }

  Widget _buildEmptyState(String activeTab) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activeTab == 'pending' ? Icons.check_circle_outline : Icons.receipt_long_outlined,
            size: 52,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            activeTab == 'pending' ? 'No Pending Invoices' : 'No Payments Recorded Yet',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            activeTab == 'pending'
                ? 'All member payments are up to date.'
                : 'Tap "Add Payment Details" below to record your first payment.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}
