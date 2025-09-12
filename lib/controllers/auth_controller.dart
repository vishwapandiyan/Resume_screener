import 'package:flutter/material.dart';
import '../models/auth_state_model.dart';
import '../services/firebase_auth_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  AuthStateModel _authState = AuthStateModel();

  AuthStateModel get authState => _authState;

  Future<void> signIn(String email, String password) async {
    try {
      _authState = _authState.copyWith(
        status: AuthStatus.loading,
        isLoading: true,
        errorMessage: null,
      );
      notifyListeners();

      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _authState = _authState.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        _authState = _authState.copyWith(
          status: AuthStatus.error,
          isLoading: false,
          errorMessage: 'Sign in failed',
        );
      }
      notifyListeners();
    } catch (e) {
      _authState = _authState.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      _authState = _authState.copyWith(
        status: AuthStatus.loading,
        isLoading: true,
        errorMessage: null,
      );
      notifyListeners();

      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      if (user != null) {
        _authState = _authState.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        _authState = _authState.copyWith(
          status: AuthStatus.error,
          isLoading: false,
          errorMessage: 'Sign up failed',
        );
      }
      notifyListeners();
    } catch (e) {
      _authState = _authState.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _authState = AuthStateModel();
      notifyListeners();
    } catch (e) {
      _authState = _authState.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = _authService.getCurrentUserModel();
      if (user != null) {
        _authState = _authState.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        _authState = _authState.copyWith(status: AuthStatus.unauthenticated);
      }
      notifyListeners();
    } catch (e) {
      _authState = _authState.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      _authState = _authState.copyWith(
        status: AuthStatus.loading,
        isLoading: true,
        errorMessage: null,
      );
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        _authState = _authState.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        _authState = _authState.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          errorMessage: null,
        );
      }
      notifyListeners();
    } catch (e) {
      _authState = _authState.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }
}
