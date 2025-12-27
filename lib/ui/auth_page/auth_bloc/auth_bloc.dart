import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secrete_santa/services/auth_service.dart';
import 'package:secrete_santa/services/storage_service.dart';
import 'package:secrete_santa/ui/auth_page/auth_bloc/auth_event.dart';
import 'package:secrete_santa/ui/auth_page/auth_bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthBloc({
    AuthService? authService,
    StorageService? storageService,
  })  : _authService = authService ?? AuthService(),
        _storageService = storageService ?? StorageService(),
        super(const AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<LogOutEvent>(_onLogOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  // Sign In Handler
  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authService.signIn(
        email: event.email,
        pass: event.password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Failed to sign in. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Sign Up Handler
  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authService.signUp(
        name: event.name,
        email: event.email,
        pass: event.password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Failed to sign up. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Log Out Handler
  Future<void> _onLogOut(LogOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    try {
      await _authService.logOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Check Auth Status Handler
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      // Check if user is logged in with Firebase
      if (_authService.currentUser != null) {
        final userData = await _storageService.getUserFromFirestore(
          _authService.currentUser!.uid,
        );
        
        if (userData != null) {
          emit(AuthAuthenticated(user: userData));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  // Reset Password Handler
  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authService.resetPassword(event.email);
      emit(const PasswordResetEmailSent());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
