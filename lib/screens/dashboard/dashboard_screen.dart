import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dashboard_summary.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, dashboard, child) {
            return RefreshIndicator(
              onRefresh: dashboard.refreshDashboard,

              child: _buildBody(dashboard),
            );
          },
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // BODY

  Widget _buildBody(DashboardProvider dashboard) {
    if (dashboard.isLoading && dashboard.summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboard.errorMessage != null && dashboard.summary == null) {
      return _buildErrorState(dashboard);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _buildTopBar(),

        const SizedBox(height: 20),

        const Text('MORNING', style: AppTextStyles.label),

        const SizedBox(height: 4),

        const Text('Operational Overview', style: AppTextStyles.heading1),

        const SizedBox(height: 20),

        _buildStatGrid(dashboard.summary!),

        const SizedBox(height: 24),

        const Text('Quick Actions', style: AppTextStyles.heading2),

        const SizedBox(height: 12),

        _buildQuickActions(),

        const SizedBox(height: 20),

        _buildExpiryBanner(),

        const SizedBox(height: 24),

        _buildRecentActivityHeader(),

        const SizedBox(height: 12),

        _buildRecentActivities(),
      ],
    );
  }

  // ERROR STATE

  Widget _buildErrorState(DashboardProvider dashboard) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),

            const SizedBox(height: 12),

            Text(
              dashboard.errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: dashboard.loadDashboard,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // TOP BAR

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: AppColors.tealPrimary),
        ),

        const Spacer(),

        const Text(
          'Owners Deck',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.tealPrimary,
          ),
        ),

        const Spacer(),

        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.tealPrimary,
              ),
            ),

            Positioned(
              right: 6,
              top: 5,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 4),

        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.inputFill,
          child: Icon(Icons.person, color: AppColors.textSecondary, size: 20),
        ),
      ],
    );
  }

  // STAT GRID

  Widget _buildStatGrid(DashboardSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width >= 1000) {
          columns = 4;
        } else if (width >= 650) {
          columns = 3;
        } else {
          columns = 2;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          crossAxisCount: columns,

          crossAxisSpacing: 14,
          mainAxisSpacing: 14,

          childAspectRatio: columns == 2 ? 1.55 : 1.45,

          children: [
            _StatCard(
              label: 'Total Members',
              value: '12', //summary.totalMembers.toString(),
              trailing: 'All Members',
              trailingColor: AppColors.accentGreen,
              valueColor: AppColors.tealDark,
            ),

            _StatCard(
              label: 'Active Members',
              value: '10', //summary.activeMembers.toString(),
              trailing: 'Currently Active',
              trailingColor: AppColors.textSecondary,
              valueColor: AppColors.textPrimary,
            ),

            _StatCard(
              label: 'Attendance',
              value: '8', //summary.todayAttendance.toString(),
              trailing: 'Present Today',
              trailingColor: AppColors.accentGreen,
              valueColor: AppColors.tealPrimary,
            ),

            _StatCard(
              label: 'Pending Fees',
              value: '2000', //_formatCurrency(summary.pendingFees),
              trailing: '${summary.pendingFeeMembers} Members Due',
              trailingColor: AppColors.danger,
              valueColor: AppColors.danger,
            ),

            _StatCard(
              label: 'Total Revenue',
              value: '12000', //_formatCurrency(summary.totalRevenue),
              trailing: 'All Payments',
              trailingColor: AppColors.accentGreen,
              valueColor: AppColors.textPrimary,
            ),

            _StatCard(
              label: 'Total Expenses',
              value: '2000', //_formatCurrency(summary.totalExpenses),
              trailing: 'All Expenses',
              trailingColor: AppColors.danger,
              valueColor: AppColors.textPrimary,
            ),

            _StatCard(
              label: 'Trainers',
              value: '4', //summary.totalTrainers.toString(),
              trailing: 'Total Trainers',
              trailingColor: AppColors.textSecondary,
              valueColor: AppColors.tealPrimary,
            ),
          ],
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₹${(amount / 1000000).toStringAsFixed(1)}M';
    }

    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }

    return '₹${amount.toStringAsFixed(0)}';
  }

  // QUICK ACTIONS

  Widget _buildQuickActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 800 ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          crossAxisCount: columns,

          crossAxisSpacing: 14,
          mainAxisSpacing: 14,

          childAspectRatio: 1.7,

          children: [
            _QuickActionCard(
              icon: Icons.person_add_alt_1,
              label: 'Add Members',
              onTap: () {
                // Add Members screen later.
              },
            ),

            _QuickActionCard(
              icon: Icons.fact_check_outlined,
              label: 'Attendance',
              onTap: () {
                // Attendance screen later.
              },
            ),

            _QuickActionCard(
              icon: Icons.fitness_center,
              label: 'Trainers',
              onTap: () {
                // Trainers screen later.
              },
            ),

            _QuickActionCard(
              icon: Icons.restaurant_menu,
              label: 'Diet Plans',
              onTap: () {
                // Diet Plans screen later.
              },
            ),
          ],
        );
      },
    );
  }

  // EXPIRY BANNER

  Widget _buildExpiryBanner() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.danger, size: 26),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memberships Expiring Soon',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'Expiry tracking will be connected to membership data.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: AppColors.danger),
        ],
      ),
    );
  }

  // RECENT ACTIVITY

  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        const Text('Recent Activity', style: AppTextStyles.heading2),

        TextButton(
          onPressed: () {},
          child: const Text(
            'View All',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.tealPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      children: const [
        _ActivityTile(
          icon: Icons.payments_outlined,
          iconBg: Color(0xFFDFF3E4),
          iconColor: AppColors.accentGreen,
          title: 'Recent payment activity',
          subtitle: 'Payment history will be connected here.',
          trailing: '',
          trailingColor: AppColors.accentGreen,
        ),

        SizedBox(height: 12),

        _ActivityTile(
          icon: Icons.person_add_alt_1_outlined,
          iconBg: Color(0xFFDFF6F5),
          iconColor: AppColors.tealPrimary,
          title: 'Recent member activity',
          subtitle: 'Member activity will be connected here.',
          trailing: '',
          trailingColor: AppColors.textSecondary,
        ),
      ],
    );
  }

  // BOTTOM NAVIGATION

  Widget _buildBottomNav() {
    final items = [
      (Icons.grid_view_rounded, 'Home'),
      (Icons.groups_outlined, 'Members'),
      (Icons.bar_chart_rounded, 'Reports'),
      (Icons.payments_outlined, 'Payments'),
      (Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),

      padding: const EdgeInsets.symmetric(vertical: 8),

      child: SafeArea(
        top: false,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: List.generate(items.length, (index) {
            final selected = index == _currentTab;

            final (icon, label) = items[index];

            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentTab = index;
                  });
                },

                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: selected
                            ? AppColors.tealPrimary
                            : AppColors.textSecondary,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? AppColors.tealPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// STAT CARD

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String trailing;
  final Color trailingColor;
  final Color valueColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.trailing,
    required this.trailingColor,
    required this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),

              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                  ),
                ),
              ),

              Text(
                trailing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  color: trailingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// QUICK ACTION CARD

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        onTap: onTap,

        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(icon, color: AppColors.tealPrimary, size: 24),

              const SizedBox(height: 8),

              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ACTIVITY TILE

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final Color trailingColor;

  const _ActivityTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: AppColors.divider),
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),

            child: Icon(icon, color: iconColor, size: 20),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          if (trailing.isNotEmpty) const SizedBox(width: 8),

          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: trailingColor,
              ),
            ),
        ],
      ),
    );
  }
}
