import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/theme/design_tokens.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/app/locale_controller.dart';
import 'package:tcf_canada_preparation/app/theme_controller.dart';

import '../admin/admin_repository.dart';
import '../admin/admin_panel_screen.dart';
import '../auth/auth_service.dart';
import '../profile/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildSettingsHeader(context),
            const SizedBox(height: 16),
            // Account card
            AnimatedFadeSlide(
              child: Container(
                padding: DesignTokens.cardPadding,
                decoration: BoxDecoration(
                  borderRadius: DesignTokens.cardBorderRadius(),
                  color: cs.surface,
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: cs.primaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? "Utilisateur",
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? "",
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 40),
              child: _ThemeModeCard(),
            ),

            const SizedBox(height: 12),

            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 50),
              child: _LanguageModeCard(),
            ),

            const SizedBox(height: 12),

            // Admin Panel (only for admins)
            FutureBuilder<bool>(
              future: AdminRepository.isCurrentUserAdmin(),
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return Column(
                  children: [
                    AnimatedFadeSlide(
                      delay: const Duration(milliseconds: 65),
                      child: Semantics(
                        button: true,
                        label: 'Ouvrir le panneau d\'administration',
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          tileColor: cs.primaryContainer.withValues(
                            alpha: 0.25,
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: cs.primary,
                          ),
                          title: const Text("Administration"),
                          subtitle: const Text("Gerer les utilisateurs"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                          minVerticalPadding: 12,
                          onTap: () {
                            Navigator.push(
                              context,
                              AppRoutes.fadeSlide(const AdminPanelScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),

            // Profile navigation
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 60),
              child: Semantics(
                button: true,
                label: 'Ouvrir les details du profil',
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                  leading: const Icon(Icons.account_circle_rounded),
                  title: const Text("Profil"),
                  subtitle: const Text("Voir les details du compte"),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  minVerticalPadding: 12,
                  onTap: () {
                    Navigator.push(
                      context,
                      AppRoutes.fadeSlide(const ProfileScreen()),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Logout
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 110),
              child: Semantics(
                button: true,
                label: 'Se deconnecter du compte',
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                  leading: Icon(Icons.logout_rounded, color: cs.error),
                  title: Text(
                    "Deconnexion",
                    style: TextStyle(
                      color: cs.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: const Text("Quitter votre compte"),
                  minVerticalPadding: 12,
                  onTap: () async {
                    final ok = await _confirmLogout(context);
                    if (!ok) return;

                    await AuthService.logout();

                    if (!context.mounted) return;

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest.withValues(alpha: 0.6),
            cs.surfaceContainerLow.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.settings_rounded, color: cs.onSurface, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parametres',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Theme, langue et compte',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Deconnexion"),
            content: const Text("Confirmez-vous la deconnexion ?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annuler"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Se deconnecter"),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _ThemeModeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeController = context.watch<ThemeController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.palette_rounded),
              SizedBox(width: 8),
              Text("Theme", style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                icon: Icon(Icons.phone_android_rounded),
                label: Text("Systeme"),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_rounded),
                label: Text("Clair"),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_rounded),
                label: Text("Sombre"),
              ),
            ],
            selected: <ThemeMode>{themeController.themeMode},
            onSelectionChanged: (selection) {
              final mode = selection.first;
              themeController.setThemeMode(mode);
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageModeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final localeController = context.watch<LocaleController>();
    final locale = localeController.locale;
    final String value = locale == null ? "system" : locale.languageCode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.language_rounded),
              SizedBox(width: 8),
              Text("Langue", style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: "system",
                icon: Icon(Icons.settings_suggest_rounded),
                label: Text("Systeme"),
              ),
              ButtonSegment<String>(
                value: "en",
                icon: Icon(Icons.translate_rounded),
                label: Text("Anglais"),
              ),
              ButtonSegment<String>(
                value: "fr",
                icon: Icon(Icons.translate_rounded),
                label: Text("Francais"),
              ),
            ],
            selected: <String>{value},
            onSelectionChanged: (selection) {
              final selected = selection.first;
              if (selected == "system") {
                localeController.setLocale(null);
              } else {
                localeController.setLocale(Locale(selected));
              }
            },
          ),
        ],
      ),
    );
  }
}
