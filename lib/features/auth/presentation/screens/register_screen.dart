import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.authService,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.onRegisterSuccess,
  });

  final AuthService authService;
  final Locale currentLocale;
  final void Function(Locale) onLocaleChanged;
  final VoidCallback onRegisterSuccess;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      // ignore: avoid_print
      print('[RegisterScreen] _submit() invoked');
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      // ignore: avoid_print
      print('[RegisterScreen] Attempting register with '
          'name="${_nameController.text.trim()}", email="$email"');
      await widget.authService.register(
        name: _nameController.text.trim(),
        email: email,
        password: password,
      );
      // ignore: avoid_print
      print('[RegisterScreen] Registration succeeded, calling onRegisterSuccess');
      if (mounted) widget.onRegisterSuccess();
    } on ArgumentError catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        String msg = e.message ?? loc.fieldRequired;
        if (e.message?.contains('already exists') == true) msg = loc.emailExists;
        if (e.message?.contains('6 characters') == true) msg = loc.passwordTooShort;
        // ignore: avoid_print
        print('[RegisterScreen] ArgumentError during register: ${e.message}');
        setState(() {
          _error = msg;
          _loading = false;
        });
      }
    } catch (e, stack) {
      // ignore: avoid_print
      print('[RegisterScreen] Unexpected error during register: $e');
      // ignore: avoid_print
      print('[RegisterScreen] Stack trace:\n$stack');
      if (mounted) {
        final loc = AppLocalizations.of(context);
        final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
        setState(() {
          _error = '${loc.error} $message';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appBarGradient = isDark ? AppTheme.primaryGradientDark : AppTheme.primaryGradientLight;
    final surfaceGradient = isDark ? AppTheme.surfaceGradientDark : AppTheme.surfaceGradientLight;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: surfaceGradient),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: topPadding),
                decoration: BoxDecoration(gradient: appBarGradient),
                child: AppBar(
                  title: Text(
                    loc.appTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          loc.registerTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: loc.name,
                            hintText: loc.name,
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLow,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return loc.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: loc.email,
                            hintText: 'example@email.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLow,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return loc.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: loc.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLow,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return loc.fieldRequired;
                            }
                            if (v.length < 6) {
                              return loc.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: loc.confirmPassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLow,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return loc.fieldRequired;
                            }
                            if (v != _passwordController.text) {
                              return loc.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        _GradientButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) _submit();
                                },
                          label: loc.register,
                          gradient: appBarGradient,
                          loading: _loading,
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(loc.haveAccount),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.onPressed,
    required this.label,
    required this.gradient,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final LinearGradient gradient;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : gradient,
        borderRadius: BorderRadius.circular(14),
        color: onPressed == null ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: onPressed == null
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
