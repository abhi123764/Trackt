class Expense {
  final int? id;
  final String category;
  final String? addCategory;
  final double amount;
  final String date;
  final String? notes;
  final String? receiptPath;

  Expense({
    this.id,
    required this.category,
    this.addCategory,
    required this.amount,
    required this.date,
    this.notes,
    this.receiptPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'add_category': addCategory,
      'amount': amount,
      'date': date,
      'notes': notes,
      'receipt_path': receiptPath,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      category: map['category'],
      addCategory: map['add_category'],
      amount: (map['amount'] as num).toDouble(),
      date: map['date'],
      notes: map['notes'],
      receiptPath: map['receipt_path'],
    );
  }
}