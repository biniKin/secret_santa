import 'package:equatable/equatable.dart';
import 'package:secrete_santa/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final int totalGroups;

  const ProfileLoaded({required this.user, required this.totalGroups});

  @override
  List<Object?> get props => [user, totalGroups];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SignOutSuccess extends ProfileState {
  const SignOutSuccess();
}
