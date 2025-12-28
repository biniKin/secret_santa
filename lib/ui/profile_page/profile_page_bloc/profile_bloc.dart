import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secrete_santa/services/auth_service.dart';
import 'package:secrete_santa/services/storage_service.dart';
import 'package:secrete_santa/ui/profile_page/profile_page_bloc/profile_event.dart';
import 'package:secrete_santa/ui/profile_page/profile_page_bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService _authService;
  final StorageService _storageService;

  ProfileBloc({AuthService? authService, StorageService? storageService})
    : _authService = authService ?? AuthService(),
      _storageService = storageService ?? StorageService(),
      super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(const ProfileError(message: 'No user logged in'));
        return;
      }

      final user = await _storageService.getUserFromFirestore(currentUser.uid);
      if (user == null) {
        emit(const ProfileError(message: 'User data not found'));
        return;
      }

      // Get user's groups count
      final userGroups = await _storageService.getUserGroups(currentUser.uid);
      final totalGroups = userGroups.length;

      emit(ProfileLoaded(user: user, totalGroups: totalGroups));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      await _authService.logOut();
      emit(const SignOutSuccess());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
