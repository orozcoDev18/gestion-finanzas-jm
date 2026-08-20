import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  const RegisterScreen({
    super.key,
    required this.onRegister,
    required this.onLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      widget.onRegister();
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
    if (msg.contains('email-already-in-use')) return 'Este email ya está registrado';
    if (msg.contains('invalid-email')) return 'Email inválido';
    if (msg.contains('weak-password')) return 'Contraseña muy débil';
    return 'Error al crear la cuenta';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: widget.onLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Crear Cuenta',
                  style: Theme.of(context).textTheme.headlineLarge,
                ).animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 8),
                Text(
                  'Regístrate para empezar',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 32),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
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
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Juan Pérez',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa tu nombre';
                    if (value.length < 2) return 'Nombre muy corto';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
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
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
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
                    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
                    if (value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signUp(),
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Crear Cuenta'),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onLogin,
                  child: RichText(
                    text: TextSpan(
                      text: '¿Ya tienes cuenta? ',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Inicia sesión',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
