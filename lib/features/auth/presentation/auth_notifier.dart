import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    return AuthState(
      isAuthenticated: _repository.isAuthenticated,
      isMockMode: _repository.isMockMode,
      userId: _repository.currentUserId,
      email: _repository.currentEmail,
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signIn(email: email, password: password);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isMockMode: _repository.isMockMode,
        userId: _repository.currentUserId,
        email: _repository.currentEmail,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signUp(email: email, password: password);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isMockMode: _repository.isMockMode,
        userId: _repository.currentUserId,
        email: _repository.currentEmail,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
    state = const AuthState(isAuthenticated: false);
  }

  void enterDemoPass() {
    _repository.enterDemoPass();
    state = state.copyWith(
      isAuthenticated: true,
      isMockMode: true,
      userId: _repository.currentUserId,
      email: _repository.currentEmail,
      errorMessage: null,
    );
  }
}
