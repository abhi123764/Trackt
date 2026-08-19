class DietPlan {
  final int? id;
  final String name;
  final String? category;
  final double? calories;
  final double? proteinPercentage;
  final double? carbsPercentage;
  final double? fatPercentage;
  final String? description;
  final String? imagePath;

  DietPlan({
    this.id,
    required this.name,
    this.category,
    this.calories,
    this.proteinPercentage,
    this.carbsPercentage,
    this.fatPercentage,
    this.description,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'calories': calories,
      'protein_percentage': proteinPercentage,
      'carbs_percentage': carbsPercentage,
      'fat_percentage': fatPercentage,
      'description': description,
      'image_path': imagePath,
    };
  }

  factory DietPlan.fromMap(Map<String, dynamic> map) {
    return DietPlan(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      calories: (map['calories'] as num?)?.toDouble(),
      proteinPercentage:
          (map['protein_percentage'] as num?)?.toDouble(),
      carbsPercentage:
          (map['carbs_percentage'] as num?)?.toDouble(),
      fatPercentage:
          (map['fat_percentage'] as num?)?.toDouble(),
      description: map['description'],
      imagePath: map['image_path'],
    );
  }
}