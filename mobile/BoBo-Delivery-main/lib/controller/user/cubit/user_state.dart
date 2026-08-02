import 'package:bobo/controller/user/models/user_model.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserLoaded extends UserState {
  final UserModel user;
  final String? localImagePath;

  UserLoaded(this.user, {this.localImagePath});
}

final class UserError extends UserState {
  final String message;

  UserError(this.message);
}
