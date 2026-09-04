import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackt/screens/members/add_member_screen.dart';
import 'package:trackt/screens/trainers/trainers_screen.dart';

import '../../models/dashboard_summary.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../members/members_screen.dart';
import 'widgets/activity_tile.dart';
import 'widgets/dashboard_bottom_nav.dart';
import 'widgets/dashboard_top_bar.dart';
import 'widgets/expiry_banner.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
            if (dashboard.currentTab == 1) {
              return const MembersScreen();
            }

            if (dashboard.currentTab != 0) {
              return _buildTabPlaceholder(dashboard.currentTab);
            }

            return RefreshIndicator(
              onRefresh: dashboard.refreshDashboard,
              child: _buildBody(dashboard),
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<DashboardProvider>(
        builder: (context, dashboard, child) {
          return DashboardBottomNav(
            currentTab: dashboard.currentTab,
            onTabSelected: (index) => dashboard.setTab(index),
          );
        },
      ),
    );
  }

  // TAB PLACEHOLDER
  Widget _buildTabPlaceholder(int tabIndex) {
    final titles = ['Home', 'Members', 'Reports', 'Payments', 'Settings'];
    final title = tabIndex < titles.length ? titles[tabIndex] : 'Section';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction,
              size: 56,
              color: AppColors.tealPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen Coming Soon',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.tealDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The $title feature will be connected here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
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
        const DashboardTopBar(),

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

        const ExpiryBanner(),

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
            StatCard(
              label: 'Total Members',
              value: summary.totalMembers.toString(),
              trailing: 'All Members',
              trailingColor: AppColors.accentGreen,
              valueColor: AppColors.tealDark,
              onTap: () => context.read<DashboardProvider>().setTab(1),
            ),

            StatCard(
              label: 'Active Members',
              value: summary.activeMembers.toString(),
              trailing: 'Currently Active',
              trailingColor: AppColors.textSecondary,
              valueColor: AppColors.textPrimary,
              onTap: () => context.read<DashboardProvider>().setTab(1),
            ),

            StatCard(
              label: 'Attendance',
              value: summary.todayAttendance.toString(),
              trailing: 'Present Today',
              trailingColor: AppColors.accentGreen,
              valueColor: AppColors.tealPrimary,
            ),

            StatCard(
              label: 'Pending Fees',
              value: AppFormatters.formatCurrency(summary.pendingFees),
              trailing: '${summary.pendingFeeMembers} Members Due',
              trailingColor: AppColors.danger,
              valueColor: AppColors.danger,
            ),

            StatCard(
              label: 'Total Revenue',
              value: AppFormatters.formatCurrency(summary.totalRevenue),
              trailing: 'All Payments',
              trailingColor: AppColors.accentGreen,
              valueColor: AppColors.textPrimary,
            ),

            StatCard(
              label: 'Total Expenses',
              value: AppFormatters.formatCurrency(summary.totalExpenses),
              trailing: 'All Expenses',
              trailingColor: AppColors.danger,
              valueColor: AppColors.textPrimary,
            ),

            StatCard(
              label: 'Trainers',
              value: summary.totalTrainers.toString(),
              trailing: 'Total Trainers',
              trailingColor: AppColors.textSecondary,
              valueColor: AppColors.tealPrimary,
            ),
          ],
        );
      },
    );
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
            QuickActionCard(
              icon: Icons.person_add_alt_1,
              label: 'Add Members',
              onTap: () {
                context.read<DashboardProvider>().setTab(1);
                showDialog(
                  context: context,
                  builder: (_) => const AddMemberScreen(),
                );
              },
            ),

            QuickActionCard(
              icon: Icons.fact_check_outlined,
              label: 'Attendance',
              onTap: () {
                // Attendance screen later.
              },
            ),

            QuickActionCard(
              icon: Icons.fitness_center,
              label: 'Trainers',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrainersScreen()),
                );

                // Trainers screen later.
              },
            ),

            QuickActionCard(
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
    return const Column(
      children: [
        ActivityTile(
          icon: Icons.payments_outlined,
          iconBg: Color(0xFFDFF3E4),
          iconColor: AppColors.accentGreen,
          title: 'Recent payment activity',
          subtitle: 'Payment history will be connected here.',
          trailing: '',
          trailingColor: AppColors.accentGreen,
        ),

        SizedBox(height: 12),

        ActivityTile(
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
}
