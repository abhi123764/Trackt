class MembershipPlan {
  final int? id;
  final String name;
  final int durationDays;
  final double price;

  MembershipPlan({
    this.id,
    required this.name,
    required this.durationDays,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration_days': durationDays,
      'price': price,
    };
  }

  factory MembershipPlan.fromMap(Map<String, dynamic> map) {
    return MembershipPlan(
      id: map['id'],
      name: map['name'],
      durationDays: map['duration_days'],
      price: (map['price'] as num).toDouble(),
    );
  }
}