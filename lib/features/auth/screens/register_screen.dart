import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';

import '../auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await AuthService.register(
        username: _username.text,
        email: _email.text,
        password: _password.text,
      );
    } catch (e) {
      _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(msg),
      ),
    );
  }

  String _friendlyError(String raw) {
    final t = raw.toLowerCase();
    if (t.contains('email-already-in-use')) return "This email is already registered.";
    if (t.contains('weak-password')) return "Password is too weak (min 6 characters).";
    if (t.contains('invalid-email')) return "Invalid email address.";
    if (t.contains('network')) return "Network error. Please try again.";
    return "Registration failed. Please try again.";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isWide = Responsive.isAuthWideLayout(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              cs.secondaryContainer.withValues(alpha: 0.35),
              cs.surface,
              cs.primaryContainer.withValues(alpha: 0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 520 : 560),
                child: StaggeredColumn(
                  spacing: 12,
                  children: [
                    Hero(
                      tag: 'auth_brand',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.secondaryContainer.withValues(alpha: 0.9),
                            boxShadow: [
                              BoxShadow(
                                color: cs.secondary.withValues(alpha: 0.2),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(Icons.person_add_rounded, size: 44, color: cs.primary),
                        ),
                      ),
                    ),
                    Text(
                      l10n.registerTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      l10n.registerSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedFadeSlide(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: cs.surface,
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _username,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: l10n.usernameLabel,
                                  prefixIcon: const Icon(Icons.badge_rounded),
                                ),
                                validator: (v) {
                                  final value = (v ?? "").trim();
                                  if (value.isEmpty) return "Username is required";
                                  if (value.length < 3) return "Minimum 3 characters";
                                  if (value.length > 20) return "Maximum 20 characters";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: l10n.emailLabel,
                                  prefixIcon: const Icon(Icons.email_rounded),
                                ),
                                validator: (v) {
                                  final value = (v ?? "").trim();
                                  if (value.isEmpty) return "Email is required";
                                  if (!value.contains('@')) return "Enter a valid email";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _password,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: l10n.passwordLabel,
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                    icon: Icon(_obscure
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded),
                                  ),
                                ),
                                validator: (v) {
                                  final value = (v ?? "");
                                  if (value.isEmpty) return "Password is required";
                                  if (value.length < 6) return "Minimum 6 characters";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirm,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  labelText: l10n.confirmPasswordLabel,
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                ),
                                validator: (v) {
                                  final value = v ?? "";
                                  if (value.isEmpty) return "Confirm your password";
                                  if (value != _password.text) return "Passwords do not match";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _loading ? null : _submit,
                                  child: _loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Text(l10n.createAccountCta),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.alreadyHaveAccount,
                                    style: TextStyle(
                                      color: cs.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _loading
                                        ? null
                                        : () {
                                            Navigator.pushReplacement(
                                              context,
                                              AppRoutes.fadeSlide(const LoginScreen()),
                                            );
                                          },
                                    child: const Text("Login"),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}
