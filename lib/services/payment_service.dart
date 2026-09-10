import '../database/database_helper.dart';
import '../models/payment.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  final DatabaseHelper _database = DatabaseHelper.instance;

  Future<int> insertPayment(Payment payment) async {
    return await _database.insertPayment(payment);
  }

  Future<List<Payment>> getAllPayments() async {
    return await _database.getAllPayments();
  }

  Future<List<Payment>> getPaymentsForMember(int memberId) async {
    return await _database.getPaymentsForMember(memberId);
  }

  Future<int> deletePayment(int id) async {
    return await _database.deletePayment(id);
  }

  Future<double> getTodayCollectedRevenue(String today) async {
    return await _database.getTodayCollectedRevenue(today);
  }

  Future<double> getYesterdayCollectedRevenue(String yesterday) async {
    return await _database.getYesterdayCollectedRevenue(yesterday);
  }

  Future<double> getMonthlyRevenue(String yearMonth) async {
    return await _database.getMonthlyRevenue(yearMonth);
  }

  Future<({double totalAmount, int count})> getPendingPaymentsSummary() async {
    return await _database.getPendingPaymentsSummary();
  }

  Future<List<Map<String, dynamic>>> getPaymentsWithDetails({
    String? status,
    int? limit,
  }) async {
    return await _database.getPaymentsWithDetails(status: status, limit: limit);
  }
}
