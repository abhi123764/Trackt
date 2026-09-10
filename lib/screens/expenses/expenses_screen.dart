import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/formatters.dart';
import 'widgets/add_expense_sheet.dart';

class ExpensesScreen extends StatefulWidget {
  final bool showBackButton;
  final bool isEmbedded;

  const ExpensesScreen({
    super.key,
    this.showBackButton = true,
    this.isEmbedded = false,
  });

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  void _navigateBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.read<DashboardProvider>().setTab(0);
    }
  }

  void _openAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddExpenseSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: Color(0xFF054446)),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildMonthlyExpensesCard(provider),

              const SizedBox(height: 16),
              _buildRecentExpensesCard(provider),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<ExpenseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF054446)),
              );
            }

            return RefreshIndicator(
              color: const Color(0xFF054446),
              onRefresh: provider.fetchExpenses,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildMonthlyExpensesCard(provider),
                    const SizedBox(height: 16),
                    _buildRecentExpensesCard(provider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseSheet,
        backgroundColor: const Color(0xFF054446),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // 1. TOP HEADER (Back button, Expenses title, bell icon, user avatar)
  Widget _buildHeader(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final initial = currentUser?.initial ?? 'U';

    return Row(
      children: [
        if (widget.showBackButton && Navigator.of(context).canPop()) ...[
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
        ],
        const Expanded(
          child: Text(
            'Expenses',
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
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // 2. REVENUE / MONTHLY PROGRESS CARD
  Widget _buildMonthlyExpensesCard(ExpenseProvider provider) {
    final monthlyExpenses = provider.monthlyExpenses;

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
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expences this Month',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.formatCurrency(monthlyExpenses),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101828),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 3. RECENT EXPENSES CARD
  Widget _buildRecentExpensesCard(ExpenseProvider provider) {
    final expenses = provider.expenses;

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
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Expenses',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          if (expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No recent expenses recorded.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF98A2B3),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 24, color: Color(0xFFF2F4F7)),
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return _buildExpenseTile(context, expense);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(BuildContext context, Expense expense) {
    final title = expense.addCategory?.isNotEmpty == true
        ? expense.addCategory!
        : expense.category;
    final formattedDate = _formatExpenseDate(expense.date);
    final formattedAmount = '- ${AppFormatters.formatCurrency(expense.amount)}';
    final categoryColor = _getCategoryColor(expense.category);
    final iconData = _getCategoryIcon(expense.category);

    return Row(
      children: [
        // Category Icon Box
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconData, size: 22, color: categoryColor),
        ),
        const SizedBox(width: 14),

        // Title and Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),

        // Negative Amount
        Text(
          formattedAmount,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('salaries') || lower.contains('salary')) {
      return const Color(0xFFF43F5E); // Rose / Pink from mockup
    } else if (lower.contains('rent') || lower.contains('lease')) {
      return const Color(0xFF0EA5E9); // Sky Blue
    } else if (lower.contains('utilit') || lower.contains('maint')) {
      return const Color(0xFF10B981); // Emerald Green
    } else if (lower.contains('market') || lower.contains('ad')) {
      return const Color(0xFFF59E0B); // Amber / Orange
    } else {
      return const Color(0xFF054446); // Trackt Teal
    }
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('salaries') || lower.contains('salary')) {
      return Icons.payments_outlined;
    } else if (lower.contains('rent') || lower.contains('lease')) {
      return Icons.business_outlined;
    } else if (lower.contains('electric') || lower.contains('power')) {
      return Icons.bolt;
    } else if (lower.contains('maint') || lower.contains('equip')) {
      return Icons.fitness_center;
    } else if (lower.contains('market') || lower.contains('ad')) {
      return Icons.campaign_outlined;
    } else {
      return Icons.receipt_long_outlined;
    }
  }

  String _formatExpenseDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
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
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
