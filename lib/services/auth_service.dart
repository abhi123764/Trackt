import '../database/database_helper.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<AppUser?> login(String email, String password) async {
    return await DatabaseHelper.instance.loginUser(email, password);
  }

  Future<bool> register(AppUser user) async {
    final existingUser = await DatabaseHelper.instance.getUserByEmail(
      user.email,
    );

    if (existingUser != null) {
      return false;
    }

    await DatabaseHelper.instance.insertUser(user);

    return true;
  }
}
