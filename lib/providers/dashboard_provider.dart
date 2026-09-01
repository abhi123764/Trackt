import 'package:flutter/foundation.dart';

import '../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService.instance;

  DashboardSummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentTab = 0;

  DashboardSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentTab => _currentTab;

  void setTab(int index) {
    if (_currentTab == index) return;
    _currentTab = index;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _summary = await _dashboardService.getDashboardSummary();

      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _isLoading = false;

      _errorMessage = 'Unable to load dashboard data.';

      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    try {
      _summary = await _dashboardService.getDashboardSummary();

      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Unable to refresh dashboard data.';

      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
