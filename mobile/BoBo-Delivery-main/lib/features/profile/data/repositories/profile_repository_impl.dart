import 'package:bobo/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:bobo/features/profile/data/models/user_model.dart';
import 'package:bobo/features/profile/domain/repositories/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserModel?> getUser(String uid, String fallbackEmail) async {
    try {
      final userMap = await _remoteDataSource.fetchProfile();
      if (userMap != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_uid', userMap['id']?.toString() ?? uid);
        await prefs.setString('user_email', userMap['email'] ?? fallbackEmail);
        await prefs.setString('user_name', userMap['name'] ?? '');
        await prefs.setString('user_phone', userMap['phone'] ?? '');
        await prefs.setString('user_address', userMap['address'] ?? '');
        await prefs.setString('user_image_url', userMap['image_url'] ?? '');

        return UserModel.fromFirestore(userMap, uid);
      }
    } catch (_) {
      // Fallback to local cached representation or default if network fails
    }

    final prefs = await SharedPreferences.getInstance();
    return UserModel(
      uid: uid,
      name: prefs.getString('user_name') ?? 'User',
      email: prefs.getString('user_email') ?? fallbackEmail,
      phoneCode: '',
      phoneNumber: prefs.getString('user_phone') ?? '',
      birthday: '',
      address: prefs.getString('user_address') ?? '',
      imageUrl: prefs.getString('user_image_url') ?? '',
    );
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final phoneStr = user.phoneCode.isNotEmpty
          ? '+${user.phoneCode.replaceAll('+', '')} ${user.phoneNumber}'
          : user.phoneNumber;

      final userMap = await _remoteDataSource.updateProfile(
        name: user.name,
        phone: phoneStr,
        address: user.address,
      );

      if (userMap != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', userMap['name'] ?? user.name);
        await prefs.setString('user_phone', userMap['phone'] ?? phoneStr);
        await prefs.setString('user_address', userMap['address'] ?? user.address);
        await prefs.setString('user_image_url', userMap['image_url'] ?? user.imageUrl);
      }
    } catch (e) {
      throw 'Failed to save profile: $e';
    }
  }
}
