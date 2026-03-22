import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';

import '../auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await AuthService.login(
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
    if (t.contains('wrong-password') || t.contains('invalid-credential')) {
      return "Incorrect email or password.";
    }
    if (t.contains('user-not-found')) return "No account found with this email.";
    if (t.contains('network')) return "Network error. Please try again.";
    if (t.contains('invalid-email')) return "Invalid email address.";
    return "Login failed. Please try again.";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primaryContainer.withValues(alpha: 0.45),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.25),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 480 : 520),
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
                            color: cs.primaryContainer.withValues(alpha: 0.85),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(Icons.lock_rounded, size: 44, color: cs.primary),
                        ),
                      ),
                    ),
                    Text(
                      "Welcome back",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      "Login to access all tests",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedFadeSlide(
                      delay: const Duration(milliseconds: 120),
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
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: Icon(Icons.email_rounded),
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
                                decoration: InputDecoration(
                                  labelText: "Password",
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
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            AppRoutes.fadeSlide(const ForgotPasswordScreen()),
                                          );
                                        },
                                  child: const Text("Forgot password?"),
                                ),
                              ),
                              const SizedBox(height: 6),
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
                                      : const Text("Login"),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "No account?",
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
                                              AppRoutes.fadeSlide(const RegisterScreen()),
                                            );
                                          },
                                    child: const Text("Create one"),
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
