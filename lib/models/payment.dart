class Payment {
  final int? id;
  final int? memberId;
  final int? planId;
  final double amount;
  final String paymentDate;
  final String? dueDate;
  final String? transactionId;
  final String? notes;
  final String paymentMethod;
  final String status;

  Payment({
    this.id,
    this.memberId,
    this.planId,
    required this.amount,
    required this.paymentDate,
    this.dueDate,
    this.transactionId,
    this.notes,
    this.paymentMethod = 'Cash',
    this.status = 'Paid',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'plan_id': planId,
      'amount': amount,
      'payment_date': paymentDate,
      'due_date': dueDate,
      'transaction_id': transactionId,
      'notes': notes,
      'payment_method': paymentMethod,
      'status': status,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      memberId: map['member_id'],
      planId: map['plan_id'],
      amount: (map['amount'] as num).toDouble(),
      paymentDate: map['payment_date'],
      dueDate: map['due_date'],
      transactionId: map['transaction_id'],
      notes: map['notes'],
      paymentMethod: map['payment_method'],
      status: map['status'],
    );
  }
}
