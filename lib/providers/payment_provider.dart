import 'package:flutter/foundation.dart';

import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service = PaymentService.instance;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _payments = [];
  String _activeTab = 'pending'; // 'pending' or 'history'

  double _collectedToday = 0.0;
  double _collectedYesterday = 0.0;
  double _monthlyRevenue = 0.0;
  double _monthlyGoal = 600000.0; // ₹6L default
  double _pendingAmount = 0.0;
  int _pendingCount = 0;

  // ── FILTER STATE ────────────────────────────────────────────────────────
  /// null = All plans
  String? _planFilter;

  /// 'All' | 'Today' | 'This Week' | 'This Month' | 'Custom'
  String _dateFilter = 'All';
  DateTime? _customFromDate;
  DateTime? _customToDate;

  /// null = All methods
  String? _methodFilter;

  // ── GETTERS ──────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get payments => _payments;
  String get activeTab => _activeTab;

  double get collectedToday => _collectedToday;
  double get collectedYesterday => _collectedYesterday;
  double get monthlyRevenue => _monthlyRevenue;
  double get monthlyGoal => _monthlyGoal;
  double get pendingAmount => _pendingAmount;
  int get pendingCount => _pendingCount;

  String? get planFilter => _planFilter;
  String get dateFilter => _dateFilter;
  DateTime? get customFromDate => _customFromDate;
  DateTime? get customToDate => _customToDate;
  String? get methodFilter => _methodFilter;

  bool get hasActiveFilters =>
      _planFilter != null || _dateFilter != 'All' || _methodFilter != null;

  int get activeFilterCount {
    int n = 0;
    if (_planFilter != null) n++;
    if (_dateFilter != 'All') n++;
    if (_methodFilter != null) n++;
    return n;
  }

  // ── COMPUTED GETTERS ─────────────────────────────────────────────────────
  void setMonthlyGoal(double goal) {
    _monthlyGoal = goal;
    notifyListeners();
  }

  double get todayTrendPercent {
    if (_collectedYesterday <= 0) {
      return _collectedToday > 0 ? 100.0 : 0.0;
    }
    return ((_collectedToday - _collectedYesterday) / _collectedYesterday) *
        100.0;
  }

  double get monthlyGoalPercent {
    if (_monthlyGoal <= 0) return 0.0;
    return (_monthlyRevenue / _monthlyGoal * 100.0).clamp(0.0, 100.0);
  }

  double get monthlyRemaining {
    final diff = _monthlyGoal - _monthlyRevenue;
    return diff > 0 ? diff : 0.0;
  }

  // ── FILTER SETTERS ───────────────────────────────────────────────────────
  void setPlanFilter(String? plan) {
    _planFilter = plan;
    notifyListeners();
  }

  void setDateFilter(String range, {DateTime? from, DateTime? to}) {
    _dateFilter = range;
    if (range == 'Custom') {
      _customFromDate = from;
      _customToDate = to;
    } else {
      _customFromDate = null;
      _customToDate = null;
    }
    notifyListeners();
  }

  void setMethodFilter(String? method) {
    _methodFilter = method;
    notifyListeners();
  }

  void resetFilters() {
    _planFilter = null;
    _dateFilter = 'All';
    _customFromDate = null;
    _customToDate = null;
    _methodFilter = null;
    notifyListeners();
  }

  // ── FILTERED PAYMENTS ────────────────────────────────────────────────────
  List<Map<String, dynamic>> get filteredPayments {
    List<Map<String, dynamic>> result = List.of(_payments);

    // 1. Tab (pending / history)
    if (_activeTab == 'pending') {
      result = result
          .where(
            (p) => (p['status'] as String?)?.toLowerCase() == 'pending',
          )
          .toList();
    }

    // 2. Plan name filter
    if (_planFilter != null) {
      final fl = _planFilter!.toLowerCase();
      result = result.where((p) {
        final name = (p['plan_name'] as String? ?? '').toLowerCase();
        return name.contains(fl);
      }).toList();
    }

    // 3. Date range filter
    if (_dateFilter != 'All') {
      final now = DateTime.now();
      DateTime? from;
      DateTime? to;

      switch (_dateFilter) {
        case 'Today':
          from = DateTime(now.year, now.month, now.day);
          to = from.add(const Duration(days: 1));
          break;
        case 'This Week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          from = DateTime(weekStart.year, weekStart.month, weekStart.day);
          to = from.add(const Duration(days: 7));
          break;
        case 'This Month':
          from = DateTime(now.year, now.month, 1);
          to = DateTime(now.year, now.month + 1, 1);
          break;
        case 'Custom':
          from = _customFromDate;
          to = _customToDate?.add(const Duration(days: 1));
          break;
      }

      if (from != null) {
        result = result.where((p) {
          final dateStr = p['payment_date'] as String? ?? '';
          final date = DateTime.tryParse(dateStr);
          if (date == null) return false;
          if (date.isBefore(from!)) return false;
          if (to?.isBefore(date) == true) return false;
          return true;
        }).toList();
      }
    }

    // 4. Payment method filter
    if (_methodFilter != null) {
      final fl = _methodFilter!.toLowerCase();
      result = result.where((p) {
        final m = (p['payment_method'] as String? ?? '').toLowerCase();
        return m == fl;
      }).toList();
    }

    return result;
  }

  // ── ACTIONS ──────────────────────────────────────────────────────────────
  void setActiveTab(String tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  Future<void> fetchPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T').first;
      final yesterdayStr =
          now.subtract(const Duration(days: 1)).toIso8601String().split('T').first;
      final monthStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      _collectedToday = await _service.getTodayCollectedRevenue(todayStr);
      _collectedYesterday =
          await _service.getYesterdayCollectedRevenue(yesterdayStr);
      _monthlyRevenue = await _service.getMonthlyRevenue(monthStr);

      final pendingInfo = await _service.getPendingPaymentsSummary();
      _pendingAmount = pendingInfo.totalAmount;
      _pendingCount = pendingInfo.count;

      _payments = await _service.getPaymentsWithDetails();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching payments: $e\n$stackTrace');
      _errorMessage = 'Failed to load payments data.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPayment({
    required int? memberId,
    int? planId,
    required double amount,
    required String paymentDate,
    String? dueDate,
    String? transactionId,
    String? notes,
    String paymentMethod = 'Cash',
    String status = 'Paid',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final payment = Payment(
        memberId: memberId,
        planId: planId,
        amount: amount,
        paymentDate: paymentDate,
        dueDate: dueDate,
        transactionId: transactionId,
        notes: notes,
        paymentMethod: paymentMethod,
        status: status,
      );

      await _service.insertPayment(payment);
      await fetchPayments();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error adding payment: $e\n$stackTrace');
      _errorMessage = 'Failed to add payment.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePayment(int id) async {
    try {
      await _service.deletePayment(id);
      await fetchPayments();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error deleting payment: $e\n$stackTrace');
      return false;
    }
  }
}
