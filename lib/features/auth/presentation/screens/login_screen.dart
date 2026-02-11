import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.onLoginSuccess,
  });

  final AuthService authService;
  final Locale currentLocale;
  final void Function(Locale) onLocaleChanged;
  final VoidCallback onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await widget.authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) widget.onLoginSuccess();
    } on ArgumentError catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message ?? AppLocalizations.of(context).invalidEmailPassword;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).invalidEmailPassword;
          _loading = false;
        });
      }
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          authService: widget.authService,
          currentLocale: widget.currentLocale,
          onLocaleChanged: widget.onLocaleChanged,
          onRegisterSuccess: () {
            Navigator.of(context).pop();
            widget.onLoginSuccess();
          },
        ),
      ),
    );
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
                          loc.loginTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
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
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
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
                          onPressed: _loading ? null : () {
                            if (_formKey.currentState!.validate()) _submit();
                          },
                          label: loc.login,
                          gradient: appBarGradient,
                          loading: _loading,
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: _loading ? null : _goToRegister,
                          child: Text(loc.noAccount),
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
