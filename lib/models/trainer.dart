class Trainer {
  final int? id;
  final String name;
  final int age;
  final String? gender;
  final String? dob;
  final String? bloodGroup;
  final String? mobileNumber;
  final String? email;
  final String? address;
  final String? profilePhotoPath;
  final String? idProofPath;
  final String? qualification;
  final String? certificatePhotoPath;
  final String? experience;
  final String? shiftStart;
  final String? shiftEnd;
  final String joiningDate;
  final double salary;

  Trainer({
    this.id,
    required this.name,
    required this.age,
    this.gender,
    this.dob,
    this.bloodGroup,
    this.mobileNumber,
    this.email,
    this.address,
    this.profilePhotoPath,
    this.idProofPath,
    this.qualification,
    this.certificatePhotoPath,
    this.experience,
    this.shiftStart,
    this.shiftEnd,
    required this.joiningDate,
    this.salary = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'dob': dob,
      'blood_group': bloodGroup,
      'mobile_number': mobileNumber,
      'email': email,
      'address': address,
      'profile_photo_path': profilePhotoPath,
      'id_proof_path': idProofPath,
      'qualification': qualification,
      'certificate_photo_path': certificatePhotoPath,
      'experience': experience,
      'shift_start': shiftStart,
      'shift_end': shiftEnd,
      'joining_date': joiningDate,
      'salary': salary,
    };
  }

  factory Trainer.fromMap(Map<String, dynamic> map) {
    return Trainer(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      dob: map['dob'],
      bloodGroup: map['blood_group'],
      mobileNumber: map['mobile_number'],
      email: map['email'],
      address: map['address'],
      profilePhotoPath: map['profile_photo_path'],
      idProofPath: map['id_proof_path'],
      qualification: map['qualification'],
      certificatePhotoPath: map['certificate_photo_path'],
      experience: map['experience'],
      shiftStart: map['shift_start'],
      shiftEnd: map['shift_end'],
      joiningDate: map['joining_date'],
      salary: (map['salary'] as num).toDouble(),
    );
  }
}