import 'package:bobo/controller/user/models/user_model.dart';

class UserRepository {
  UserRepository();

  Future<UserModel?> getUser(String uid, String fallbackEmail) async {
    // Return a default model for now.
    // In the next step, this will fetch from the Laravel API (/me endpoint)
    return UserModel(
      uid: uid,
      name: 'John Doe',
      email: fallbackEmail,
      phoneCode: '1',
      phoneNumber: '5550123456',
      birthday: '1995-05-15',
      address: '456 Elm Street, Suite 4, Brooklyn, NY',
    );
  }

  Future<void> saveUser(UserModel user) async {
    // In the next step, this will send a PUT/PATCH update to the Laravel API
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
