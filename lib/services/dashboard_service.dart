import '../database/database_helper.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  DashboardService._();

  static final DashboardService instance = DashboardService._();

  final DatabaseHelper _database = DatabaseHelper.instance;

  Future<DashboardSummary> getDashboardSummary() async {
    final data = await _database.getDashboardSummary();

    return DashboardSummary.fromMap(data);
  }
}
