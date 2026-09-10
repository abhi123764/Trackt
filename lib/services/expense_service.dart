import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseService {
  ExpenseService._();

  static final ExpenseService instance = ExpenseService._();

  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Expense>> getAllExpenses() async {
    return await _db.getAllExpenses();
  }

  Future<double> getTotalExpenses({String? fromDate, String? toDate}) async {
    return await _db.getTotalExpenses(fromDate: fromDate, toDate: toDate);
  }

  Future<Map<String, double>> getCategoryBreakdown() async {
    return await _db.getExpensesCategoryBreakdown();
  }

  Future<int> addExpense(Expense expense) async {
    return await _db.insertExpense(expense);
  }

  Future<int> updateExpense(Expense expense) async {
    return await _db.updateExpense(expense);
  }

  Future<int> deleteExpense(int id) async {
    return await _db.deleteExpense(id);
  }

  Future<double> getMonthlyRevenue(String yearMonth) async {
    return await _db.getMonthlyRevenue(yearMonth);
  }
}
