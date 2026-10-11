import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/orbit_theme.dart';
import '../../chat/presentation/widgets/cosmic_scaffold.dart';
import 'auth_notifier.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both email and password.'),
          backgroundColor: OrbitTheme.marsCrimson,
        ),
      );
      return;
    }

    final notifier = ref.read(authNotifierProvider.notifier);
    try {
      if (_isSignUp) {
        await notifier.signUp(email: email, password: password);
      } else {
        await notifier.signIn(email: email, password: password);
      }
      if (mounted) {
        context.go('/chat');
      }
    } catch (_) {
      // Error message is stored in authState
    }
  }

  void _enterAsExplorer() {
    ref.read(authNotifierProvider.notifier).enterDemoPass();
    context.go('/chat');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return CosmicScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: OrbitTheme.orbitCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: OrbitTheme.orbitCardBorder),
                boxShadow: [
                  BoxShadow(
                    color: OrbitTheme.earthCyan.withAlpha(20),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [OrbitTheme.earthCyan, OrbitTheme.jupiterViolet],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.blur_circular, color: OrbitTheme.voidBlack, size: 36),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI ORBIT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OrbitTheme.starWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Clean Architecture & Riverpod AI Gateway',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OrbitTheme.starlightMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (authState.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: OrbitTheme.marsCrimson.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: OrbitTheme.marsCrimson.withAlpha(100)),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: const TextStyle(color: OrbitTheme.marsCrimson, fontSize: 13),
                      ),
                    ),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: OrbitTheme.starWhite),
                    decoration: const InputDecoration(
                      labelText: 'Cosmic Identifier (Email)',
                      prefixIcon: Icon(Icons.alternate_email, color: OrbitTheme.starlightMuted),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: OrbitTheme.starWhite),
                    decoration: const InputDecoration(
                      labelText: 'Access Key (Password)',
                      prefixIcon: Icon(Icons.lock_outline, color: OrbitTheme.starlightMuted),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: OrbitTheme.voidBlack),
                          )
                        : Text(_isSignUp ? 'Initiate Orbit Access' : 'Authenticate Gateway'),
                  ),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    style: TextButton.styleFrom(foregroundColor: OrbitTheme.starlightMuted),
                    child: Text(
                      _isSignUp
                          ? 'Already registered? Sign In'
                          : 'New explorer? Create an Orbit identity',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),

                  const Divider(color: OrbitTheme.orbitCardBorder, height: 24),

                  OutlinedButton.icon(
                    onPressed: _enterAsExplorer,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OrbitTheme.earthCyan,
                      side: const BorderSide(color: OrbitTheme.orbitCardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.rocket_launch, size: 16),
                    label: const Text('Instant Explorer Demo Pass', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
