import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/orbit_config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  bool _mockMode = true;
  String? _mockUserId;
  String? _mockEmail;

  bool get isMockMode => _mockMode;
  bool get isAuthenticated =>
      _mockMode ? _mockUserId != null : Supabase.instance.client.auth.currentSession != null;
  String? get currentUserId =>
      _mockMode ? _mockUserId : Supabase.instance.client.auth.currentUser?.id;
  String? get currentEmail =>
      _mockMode ? _mockEmail : Supabase.instance.client.auth.currentUser?.email;
  String? get jwtToken =>
      _mockMode ? 'mock_jwt_orbit_token' : Supabase.instance.client.auth.currentSession?.accessToken;

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    if (OrbitConfig.isConfigured) {
      try {
        await Supabase.initialize(
          url: OrbitConfig.supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: OrbitConfig.supabaseAnonKey,
        );
        _mockMode = false;
        debugPrint('[AuthRepository] Live Supabase connection active: ${OrbitConfig.supabaseUrl}');
      } catch (e) {
        debugPrint('[AuthRepository] Supabase initialization failed, enabling Demo Mode: $e');
        _mockMode = true;
      }
    } else {
      _mockMode = true;
    }

    if (_mockMode) {
      _mockUserId = 'orbit-explorer-001';
      _mockEmail = 'explorer@ai-orbit.space';
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (_mockMode) {
      _mockUserId = 'orbit-user-${email.hashCode}';
      _mockEmail = email;
      return;
    }
    await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) async {
    if (_mockMode) {
      _mockUserId = 'orbit-user-${email.hashCode}';
      _mockEmail = email;
      return;
    }
    await client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    if (_mockMode) {
      _mockUserId = null;
      _mockEmail = null;
      return;
    }
    await client.auth.signOut();
  }

  void enterDemoPass() {
    _mockMode = true;
    _mockUserId = 'orbit-demo-explorer';
    _mockEmail = 'demo@ai-orbit.space';
  }
}
