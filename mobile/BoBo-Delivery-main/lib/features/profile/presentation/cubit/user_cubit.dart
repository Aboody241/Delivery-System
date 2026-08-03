import 'dart:io';
import 'package:bobo/features/profile/data/models/user_model.dart';
import 'package:bobo/features/profile/domain/repositories/profile_repository.dart';
import 'package:bobo/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  UserCubit(this._profileRepository, this._authRepository) : super(UserInitial());

  Future<void> fetchUser() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    
    if (!isLoggedIn) {
      emit(UserError('User not authenticated'));
      return;
    }

    final uid = await _authRepository.getCurrentUserUid() ?? 'guest';
    final email = await _authRepository.getCurrentUserEmail() ?? 'user@example.com';

    emit(UserLoading());

    try {
      final userModel = await _profileRepository.getUser(uid, email);
      
      if (userModel != null) {
        final prefs = await SharedPreferences.getInstance();
        final localImagePath = prefs.getString('profile_image_$uid');
        emit(UserLoaded(userModel, localImagePath: localImagePath));
      } else {
        emit(UserError('Failed to load user data'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> saveUser(UserModel updatedUser) async {
    try {
      await _profileRepository.saveUser(updatedUser);
      final currentState = state;
      String? currentImagePath;
      if (currentState is UserLoaded) {
        currentImagePath = currentState.localImagePath;
      }
      emit(UserLoaded(updatedUser, localImagePath: currentImagePath));
    } catch (e) {
      emit(UserError('Failed to save: $e'));
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    final currentState = state;
    if (currentState is UserLoaded) {
      try {
        final uid = currentState.user.uid;
        final directory = await getApplicationDocumentsDirectory();
        final newPath = '${directory.path}/profile_image_$uid.jpg';
        
        final savedImage = await imageFile.copy(newPath);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_$uid', savedImage.path);
        
        emit(UserLoaded(currentState.user, localImagePath: savedImage.path));
      } catch (e) {
        emit(UserError('Failed to save image: $e'));
      }
    }
  }
}
