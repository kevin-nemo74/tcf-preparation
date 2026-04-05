import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/core/widgets/premium_ui.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';

import '../auth_service.dart';
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
      await AuthService.login(email: _email.text, password: _password.text);
      await AppAnalytics.logLoginSuccess();
      if (!mounted) return;
      // Return to AuthGate (root). It will rebuild to the authenticated flow.
      Navigator.of(context).popUntil((route) => route.isFirst);
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
      return "E-mail ou mot de passe incorrect.";
    }
    if (t.contains('user-not-found'))
      return "Aucun compte trouve avec cet e-mail.";
    if (t.contains('network')) return "Erreur reseau. Veuillez reessayer.";
    if (t.contains('invalid-email')) return "Adresse e-mail invalide.";
    return "Connexion echouee. Veuillez reessayer.";
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
                  spacing: 14,
                  children: [
                    const PremiumBrandMark(large: true),
                    Text(
                      l10n.loginWelcomeBack,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      l10n.loginAccessTests,
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
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: cs.surface,
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.06),
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
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer.withValues(
                                    alpha: 0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.email_rounded,
                                      color: cs.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Connexion',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: cs.primary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: l10n.emailLabel,
                                  prefixIcon: const Icon(Icons.email_rounded),
                                  filled: true,
                                  fillColor: cs.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                ),
                                validator: (v) {
                                  final value = (v ?? "").trim();
                                  if (value.isEmpty)
                                    return "L'e-mail est obligatoire";
                                  if (!value.contains('@'))
                                    return "Entrez un e-mail valide";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _password,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: l10n.passwordLabel,
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: cs.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                ),
                                validator: (v) {
                                  final value = (v ?? "");
                                  if (value.isEmpty)
                                    return "Le mot de passe est obligatoire";
                                  if (value.length < 6)
                                    return "Minimum 6 caracteres";
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
                                            AppRoutes.fadeSlide(
                                              const ForgotPasswordScreen(),
                                            ),
                                          );
                                        },
                                  child: Text(l10n.forgotPasswordCta),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _loading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.login_rounded,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(l10n.loginCta),
                                          ],
                                        ),
                                ),
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
