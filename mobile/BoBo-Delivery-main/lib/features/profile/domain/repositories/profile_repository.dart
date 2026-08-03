import 'package:bobo/features/profile/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel?> getUser(String uid, String fallbackEmail);
  Future<void> saveUser(UserModel user);
}
