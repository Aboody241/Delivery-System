import 'package:bobo/controller/user/models/user_model.dart';
import 'package:bobo/services/auth_service.dart';

class UserRepository {
  final AuthService _authService = AuthService();

  UserRepository();

  Future<UserModel?> getUser(String uid, String fallbackEmail) async {
    try {
      final userMap = await _authService.fetchProfile();
      if (userMap != null) {
        return UserModel.fromFirestore(userMap, uid);
      }
    } catch (_) {
      // Fallback to local representation if network fails
    }

    return UserModel(
      uid: uid,
      name: 'User',
      email: fallbackEmail,
      phoneCode: '',
      phoneNumber: '',
      birthday: '',
      address: '',
    );
  }

  Future<void> saveUser(UserModel user) async {
    // We can implement profile updates to Backend in the future tasks
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
