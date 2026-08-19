class DietMeal {
  final int? id;
  final int planId;
  final String mealName;
  final String mealType;
  final String? quantity;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final String? imagePath;

  DietMeal({
    this.id,
    required this.planId,
    required this.mealName,
    required this.mealType,
    this.quantity,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_id': planId,
      'meal_name': mealName,
      'meal_type': mealType,
      'quantity': quantity,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'image_path': imagePath,
    };
  }

  factory DietMeal.fromMap(Map<String, dynamic> map) {
    return DietMeal(
      id: map['id'],
      planId: map['plan_id'],
      mealName: map['meal_name'],
      mealType: map['meal_type'],
      quantity: map['quantity'],
      calories: (map['calories'] as num?)?.toDouble(),
      protein: (map['protein'] as num?)?.toDouble(),
      carbs: (map['carbs'] as num?)?.toDouble(),
      fat: (map['fat'] as num?)?.toDouble(),
      imagePath: map['image_path'],
    );
  }
}