import 'package:firebase_auth/firebase_auth.dart';
import 'package:secrete_santa/models/user_model.dart';
import 'package:secrete_santa/services/storage_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _storageService = StorageService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signIn({
    required String email,
    required String pass,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (userCredential.user != null) {
        // Fetch user data from Firestore
        final userData = await _storageService.getUserFromFirestore(
          userCredential.user!.uid,
        );

        if (userData != null) {
          return userData;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during sign in: $e';
    }
  }

  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String pass,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (userCredential.user != null) {
        // Create user model
        final user = UserModel(
          userId: userCredential.user!.uid,
          name: name,
          email: email,
          hasMatch: false,
          isAdmin: false,
        );

        // Save to Firestore
        await _storageService.saveUserToFirestore(user);

        // Update display name
        await userCredential.user!.updateDisplayName(name);

        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during sign up: $e';
    }
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'An error occurred during logout: $e';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred while sending reset email: $e';
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}