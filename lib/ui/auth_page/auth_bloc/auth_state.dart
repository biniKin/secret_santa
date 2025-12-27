import 'package:equatable/equatable.dart';
import 'package:secrete_santa/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial State
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Loading State
class AuthLoading extends AuthState {
  const AuthLoading();
}

// Authenticated State (Success)
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

// Unauthenticated State
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// Error State (Failure)
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Password Reset Email Sent State
class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();
}