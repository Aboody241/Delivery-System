abstract class AuthRepository {
  Future<Map<String, dynamic>?> login(String email, String password);
  Future<Map<String, dynamic>?> register(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getCurrentUserUid();
  Future<String?> getCurrentUserEmail();
  Future<String?> getCurrentUserImageUrl();
}
