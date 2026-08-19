class DashboardSummary {
  final int totalMembers;
  final int activeMembers;
  final int todayAttendance;
  final double pendingFees;
  final int pendingFeeMembers;
  final double totalRevenue;
  final double totalExpenses;
  final int totalTrainers;

  const DashboardSummary({
    required this.totalMembers,
    required this.activeMembers,
    required this.todayAttendance,
    required this.pendingFees,
    required this.pendingFeeMembers,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalTrainers,
  });

  factory DashboardSummary.fromMap(Map<String, dynamic> map) {
    return DashboardSummary(
      totalMembers: (map['total_members'] as num?)?.toInt() ?? 0,

      activeMembers: (map['active_members'] as num?)?.toInt() ?? 0,

      todayAttendance: (map['today_attendance'] as num?)?.toInt() ?? 0,

      pendingFees: (map['pending_fees'] as num?)?.toDouble() ?? 0.0,

      pendingFeeMembers: (map['pending_fee_members'] as num?)?.toInt() ?? 0,

      totalRevenue: (map['total_revenue'] as num?)?.toDouble() ?? 0.0,

      totalExpenses: (map['total_expenses'] as num?)?.toDouble() ?? 0.0,

      totalTrainers: (map['total_trainers'] as num?)?.toInt() ?? 0,
    );
  }
}
