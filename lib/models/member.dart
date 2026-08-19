class Member {
  final int? id;
  final String name;
  final String? gender;
  final String? bloodGroup;
  final String? dob;
  final String mobileNumber;
  final String? email;
  final String? address;
  final String? profilePhotoPath;
  final String? idProofPath;
  final String? medicalReportsPath;

  final double? height;
  final double? weight;
  final double? targetWeight;
  final double? bmi;

  final String? activityLevel;
  final String? fitnessGoal;
  final String? emotionalHealth;
  final String? medicalConditions;

  final int? dietPlanId;
  final int? planId;
  final int? trainerId;

  final String? preferredTime;
  final String status;
  final String joinDate;

  Member({
    this.id,
    required this.name,
    this.gender,
    this.bloodGroup,
    this.dob,
    required this.mobileNumber,
    this.email,
    this.address,
    this.profilePhotoPath,
    this.idProofPath,
    this.medicalReportsPath,
    this.height,
    this.weight,
    this.targetWeight,
    this.bmi,
    this.activityLevel,
    this.fitnessGoal,
    this.emotionalHealth,
    this.medicalConditions,
    this.dietPlanId,
    this.planId,
    this.trainerId,
    this.preferredTime,
    this.status = 'Active',
    required this.joinDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'blood_group': bloodGroup,
      'dob': dob,
      'mobile_number': mobileNumber,
      'email': email,
      'address': address,
      'profile_photo_path': profilePhotoPath,
      'idproof_path': idProofPath,
      'medical_reports_path': medicalReportsPath,
      'height': height,
      'weight': weight,
      'target_weight': targetWeight,
      'bmi': bmi,
      'activity_level': activityLevel,
      'fitness_goal': fitnessGoal,
      'emotional_health': emotionalHealth,
      'medical_conditions': medicalConditions,
      'diet_plan_id': dietPlanId,
      'plan_id': planId,
      'trainer_id': trainerId,
      'preferred_time': preferredTime,
      'status': status,
      'join_date': joinDate,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      bloodGroup: map['blood_group'],
      dob: map['dob'],
      mobileNumber: map['mobile_number'],
      email: map['email'],
      address: map['address'],
      profilePhotoPath: map['profile_photo_path'],
      idProofPath: map['idproof_path'],
      medicalReportsPath: map['medical_reports_path'],
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      targetWeight: (map['target_weight'] as num?)?.toDouble(),
      bmi: (map['bmi'] as num?)?.toDouble(),
      activityLevel: map['activity_level'],
      fitnessGoal: map['fitness_goal'],
      emotionalHealth: map['emotional_health'],
      medicalConditions: map['medical_conditions'],
      dietPlanId: map['diet_plan_id'],
      planId: map['plan_id'],
      trainerId: map['trainer_id'],
      preferredTime: map['preferred_time'],
      status: map['status'],
      joinDate: map['join_date'],
    );
  }
}