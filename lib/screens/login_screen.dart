import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      widget.onLogin();
    } catch (e) {
      setState(() {
        _error = _getErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final msg = error.toString();
    if (msg.contains('user-not-found')) return 'Usuario no encontrado';
    if (msg.contains('wrong-password')) return 'Contraseña incorrecta';
    if (msg.contains('invalid-email')) return 'Email inválido';
    if (msg.contains('too-many-requests')) return 'Demasiados intentos. Intenta más tarde';
    return 'Error al iniciar sesión';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.purple],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 24),
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineLarge,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 48),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppColors.danger, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().shake(),
                if (_error != null) const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'tu@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa tu email';
                    if (!value.contains('@')) return 'Email inválido';
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                    if (value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Iniciar Sesión'),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onRegister,
                  child: RichText(
                    text: TextSpan(
                      text: '¿No tienes cuenta? ',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Regístrate',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),
                const SizedBox(height: 48),
                Text(
                  '© 2026 José Miguel Orozco Martínez.\nTodos los derechos reservados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.lightTextSecondary.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
