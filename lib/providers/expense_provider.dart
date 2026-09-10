import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseCategoryInfo {
  final String name;
  final double amount;
  final double percentage; // 0 to 100

  const ExpenseCategoryInfo({
    required this.name,
    required this.amount,
    required this.percentage,
  });
}

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service = ExpenseService.instance;

  List<Expense> _expenses = [];
  double _totalExpenses = 0.0;
  double _monthlyExpenses = 0.0;

  List<ExpenseCategoryInfo> _categoryBreakdown = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  double get totalExpenses => _totalExpenses;
  double get monthlyExpenses => _monthlyExpenses;

  List<ExpenseCategoryInfo> get categoryBreakdown => _categoryBreakdown;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _service.getAllExpenses();

      // Total expenses
      double sum = 0.0;
      for (var e in _expenses) {
        sum += e.amount;
      }
      _totalExpenses = sum;

      // Current month expences
      // Current month expenses
      final now = DateTime.now();
      final currentYearMonth =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      _monthlyExpenses = _expenses
          .where((expense) => expense.date.startsWith(currentYearMonth))
          .fold(0.0, (sum, expense) => sum + expense.amount);

      // Breakdown calculation
      final rawMap = await _service.getCategoryBreakdown();
      final List<ExpenseCategoryInfo> list = [];

      // Expected priority categories from mockup
      final priorityCategories = [
        'Salaries',
        'Rent/Lease',
        'Utilities & Maintenance',
        'Marketing',
      ];

      for (var cat in priorityCategories) {
        final amount = rawMap[cat] ?? 0.0;
        final pct = _totalExpenses > 0 ? (amount / _totalExpenses) * 100 : 0.0;
        list.add(
          ExpenseCategoryInfo(name: cat, amount: amount, percentage: pct),
        );
      }

      // Any remaining categories
      rawMap.forEach((cat, amount) {
        if (!priorityCategories.contains(cat)) {
          final pct = _totalExpenses > 0
              ? (amount / _totalExpenses) * 100
              : 0.0;
          list.add(
            ExpenseCategoryInfo(name: cat, amount: amount, percentage: pct),
          );
        }
      });

      _categoryBreakdown = list;
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching expenses: $e\n$stackTrace');
      _isLoading = false;
      _errorMessage = 'Failed to load expenses.';
      notifyListeners();
    }
  }

  Future<bool> addExpense({
    required String title,
    required String category,
    required double amount,
    required String date,
    String? notes,
  }) async {
    try {
      final expense = Expense(
        category: category,
        addCategory: title,
        amount: amount,
        date: date,
        notes: notes,
      );
      await _service.addExpense(expense);
      await fetchExpenses();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error adding expense: $e\n$stackTrace');
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _service.deleteExpense(id);
      await fetchExpenses();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error deleting expense: $e\n$stackTrace');
      return false;
    }
  }
}
