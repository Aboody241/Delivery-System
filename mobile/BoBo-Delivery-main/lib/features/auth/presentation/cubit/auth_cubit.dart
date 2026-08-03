import 'package:bobo/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (loggedIn) {
      final uid = await _authRepository.getCurrentUserUid() ?? 'guest';
      final email = await _authRepository.getCurrentUserEmail() ?? '';
      emit(AuthAuthenticated(uid: uid, email: email));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(email, password);
      if (result != null) {
        emit(AuthAuthenticated(
          uid: result['uid'] ?? 'guest',
          email: result['email'] ?? email,
        ));
      } else {
        emit(AuthError('Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.register(email, password);
      if (result != null) {
        emit(AuthAuthenticated(
          uid: result['uid'] ?? 'guest',
          email: result['email'] ?? email,
        ));
      } else {
        emit(AuthError('Registration failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
