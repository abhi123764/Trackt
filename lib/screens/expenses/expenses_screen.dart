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

  void _openEditExpenseSheet(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(expense: expense),
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Expense',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF101828),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this expense?\nThis action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF667085),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF667085),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (expense.id != null) {
                final provider = context.read<ExpenseProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final ok = await provider.deleteExpense(expense.id!);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? 'Expense deleted.' : 'Failed to delete expense.',
                    ),
                    backgroundColor:
                        ok ? const Color(0xFF054446) : Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFE53E3E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        onApply: (category, from, to) {
          context.read<ExpenseProvider>().setFilter(
                category: category,
                from: from,
                to: to,
              );
        },
        onClear: () {
          context.read<ExpenseProvider>().setFilter(clearAll: true);
        },
      ),
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
              _buildFilterBar(context, provider),

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
                    _buildFilterBar(context, provider),
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

  // ── HEADER ─────────────────────────────────────────────────────────────────
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

  // ── FILTER BAR ─────────────────────────────────────────────────────────────
  Widget _buildFilterBar(BuildContext context, ExpenseProvider provider) {
    final hasFilter = provider.hasActiveFilter;

    return Row(
      children: [
        // Filter button is always visible — outside the scroll area
        _FilterChipButton(
          icon: Icons.tune_rounded,
          label: 'Filter',
          isActive: hasFilter,
          onTap: () => _showFilterSheet(context),
        ),

        // Active filter chips scroll horizontally
        if (hasFilter) ...[
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (provider.filterCategory != null)
                    _ActiveFilterChip(
                      label: provider.filterCategory!,
                      onRemove: () {
                        provider.setFilter(
                          category: null,
                          from: provider.filterFrom,
                          to: provider.filterTo,
                        );
                      },
                    ),
                  if (provider.filterCategory != null &&
                      (provider.filterFrom != null ||
                          provider.filterTo != null))
                    const SizedBox(width: 8),
                  if (provider.filterFrom != null || provider.filterTo != null)
                    _ActiveFilterChip(
                      label: _buildDateRangeLabel(
                          provider.filterFrom, provider.filterTo),
                      onRemove: () {
                        provider.setFilter(
                          category: provider.filterCategory,
                          from: null,
                          to: null,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => provider.setFilter(clearAll: true),
            child: const Text(
              'Clear all',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF054446),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _buildDateRangeLabel(DateTime? from, DateTime? to) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    if (from != null && to != null) {
      return '${months[from.month - 1]} ${from.day} – ${months[to.month - 1]} ${to.day}';
    } else if (from != null) {
      return 'From ${months[from.month - 1]} ${from.day}';
    } else if (to != null) {
      return 'Until ${months[to.month - 1]} ${to.day}';
    }
    return '';
  }

  // ── MONTHLY CARD ───────────────────────────────────────────────────────────
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
            'Expenses this Month',
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

  // ── RECENT EXPENSES CARD ───────────────────────────────────────────────────
  Widget _buildRecentExpensesCard(ExpenseProvider provider) {
    final expenses = provider.filteredExpenses;
    final hasFilter = provider.hasActiveFilter;

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
          Row(
            children: [
              Text(
                hasFilter ? 'Filtered Expenses' : 'Recent Expenses',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              if (expenses.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF054446).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${expenses.length} entries',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF054446),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  hasFilter
                      ? 'No expenses match your filters.'
                      : 'No recent expenses recorded.',
                  style: const TextStyle(
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

  // ── EXPENSE TILE (with swipe + long press) ─────────────────────────────────
  Widget _buildExpenseTile(BuildContext context, Expense expense) {
    final title = expense.addCategory?.isNotEmpty == true
        ? expense.addCategory!
        : expense.category;
    final formattedDate = _formatExpenseDate(expense.date);
    final formattedAmount = '- ${AppFormatters.formatCurrency(expense.amount)}';
    final categoryColor = _getCategoryColor(expense.category);
    final iconData = _getCategoryIcon(expense.category);

    // Capture refs before any async work so we satisfy use_build_context_synchronously
    final expenseProvider = context.read<ExpenseProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Dismissible(
      key: ValueKey(expense.id ?? expense.date + expense.amount.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFE53E3E)),

      ),
      confirmDismiss: (direction) async {
        if (expense.id == null) return false;
        bool shouldDelete = false;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Delete Expense',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            content: const Text(
              'Are you sure you want to delete this expense?\nThis action cannot be undone.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF667085),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  shouldDelete = true;
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFFE53E3E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
        if (shouldDelete) {
          final ok = await expenseProvider.deleteExpense(expense.id!);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                  ok ? 'Expense deleted.' : 'Failed to delete expense.'),
              backgroundColor: ok ? const Color(0xFF054446) : Colors.red,
            ),
          );
        }
        return false; // We handle removal via provider refresh
      },
      child: GestureDetector(
        onLongPress: () => _showExpenseOptions(context, expense),
        child: Row(
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

            // Amount + action dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showExpenseOptions(context, expense),
                  child: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Color(0xFF98A2B3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseOptions(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAECF0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Expense label
            Text(
              expense.addCategory?.isNotEmpty == true
                  ? expense.addCategory!
                  : expense.category,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppFormatters.formatCurrency(expense.amount),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF2F4F7)),
            const SizedBox(height: 8),
            // Edit option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF054446).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 20, color: Color(0xFF054446)),
              ),
              title: const Text(
                'Edit Expense',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _openEditExpenseSheet(expense);
              },
            ),
            // Delete option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline,
                    size: 20, color: Color(0xFFE53E3E)),
              ),
              title: const Text(
                'Delete Expense',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE53E3E),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, expense);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('salaries') || lower.contains('salary')) {
      return const Color(0xFFF43F5E);
    } else if (lower.contains('rent') || lower.contains('lease')) {
      return const Color(0xFF0EA5E9);
    } else if (lower.contains('utilit') || lower.contains('maint')) {
      return const Color(0xFF10B981);
    } else if (lower.contains('market') || lower.contains('ad')) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFF054446);
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
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final void Function(String? category, DateTime? from, DateTime? to) onApply;
  final VoidCallback onClear;

  const _FilterSheet({required this.onApply, required this.onClear});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _selectedCategory;
  DateTime? _fromDate;
  DateTime? _toDate;

  final List<String> _categories = [
    'Salaries',
    'Rent/Lease',
    'Utilities & Maintenance',
    'Marketing',
    'Equipment & Inventory',
    'Other',
  ];

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF054446),
            onPrimary: Colors.white,
            onSurface: Color(0xFF101828),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fromDate = picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF054446),
            onPrimary: Colors.white,
            onSurface: Color(0xFF101828),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _toDate = picked);
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Select date';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAECF0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filter Expenses',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 20),

            // Category section
            const Text(
              'CATEGORY',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ..._categories.map(
                  (cat) => _CategoryChip(
                    label: cat,
                    isSelected: _selectedCategory == cat,
                    onTap: () => setState(() => _selectedCategory = cat),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date range section
            const Text(
              'DATE RANGE',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'From',
                    value: _fmt(_fromDate),
                    hasValue: _fromDate != null,
                    onTap: _pickFrom,
                    onClear: () => setState(() => _fromDate = null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateButton(
                    label: 'To',
                    value: _fmt(_toDate),
                    hasValue: _toDate != null,
                    onTap: _pickTo,
                    onClear: () => setState(() => _toDate = null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEAECF0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_selectedCategory, _fromDate, _toDate);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF054446),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF054446)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF054446)
                : const Color(0xFFD0D5DD),
            width: 1.5,
          ),
          boxShadow: isActive
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF344054),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF344054),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF054446).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF054446).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF054446),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFF054446),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF054446) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF054446)
                : const Color(0xFFEAECF0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF667085),
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateButton({
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? const Color(0xFF054446).withValues(alpha: 0.4)
                : const Color(0xFFEAECF0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 15,
              color: hasValue ? const Color(0xFF054446) : const Color(0xFF98A2B3),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF98A2B3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasValue
                          ? const Color(0xFF101828)
                          : const Color(0xFF98A2B3),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasValue)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Color(0xFF98A2B3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
