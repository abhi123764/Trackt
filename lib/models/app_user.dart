class AppUser {
  final int? id;
  final String fName;
  final String lName;
  final String email;
  final String? dob;
  final String? mobileNumber;
  final String password;
  final String? themePreference;
  final String? languagePreference;
  final String createdAt;

  AppUser({
    this.id,
    required this.fName,
    required this.lName,
    required this.email,
    this.dob,
    this.mobileNumber,
    required this.password,
    this.themePreference = 'System',
    this.languagePreference = 'English',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'email': email,
      'dob': dob,
      'mobile_number': mobileNumber,
      'password': password,
      'theme_preference': themePreference,
      'language_preference': languagePreference,
      'created_at': createdAt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      fName: map['f_name'],
      lName: map['l_name'],
      email: map['email'],
      dob: map['dob'],
      mobileNumber: map['mobile_number'],
      password: map['password'],
      themePreference: map['theme_preference'],
      languagePreference: map['language_preference'],
      createdAt: map['created_at'],
    );
  }
}