import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/theme/design_tokens.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';

import '../auth/auth_service.dart';
import '../profile/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.canvasMaxWidth(context)),
          child: ListView(
            padding: Responsive.pagePadding(context, vertical: 16),
            children: [
              // Account card
              AnimatedFadeSlide(
            child: Container(
              padding: DesignTokens.cardPadding,
              decoration: BoxDecoration(
                borderRadius: DesignTokens.cardBorderRadius(),
                color: cs.surface,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.primaryContainer.withOpacity(0.7),
                    child: Icon(Icons.person_rounded, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "User",
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "",
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.65),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.6)),
                ],
              ),
            ),
              ),

              const SizedBox(height: 12),

              // Profile navigation
              AnimatedFadeSlide(
            delay: const Duration(milliseconds: 60),
            child: Semantics(
              button: true,
              label: 'Open profile details',
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: cs.surfaceContainerHighest.withOpacity(0.35),
                leading: const Icon(Icons.account_circle_rounded),
                title: const Text("Profile"),
                subtitle: const Text("View account details"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
              label: 'Logout from account',
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: cs.surfaceContainerHighest.withOpacity(0.35),
                leading: Icon(Icons.logout_rounded, color: cs.error),
                title: Text(
                  "Logout",
                  style: TextStyle(color: cs.error, fontWeight: FontWeight.w800),
                ),
                subtitle: const Text("Sign out of your account"),
                minVerticalPadding: 12,
                onTap: () async {
                  final ok = await _confirmLogout(context);
                  if (!ok) return;

                  await AuthService.logout();

                  if (!context.mounted) return;

                  // ✅ Immediately return to root (AuthGate),
                  // which will show LoginScreen since user is signed out
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    ) ??
        false;
  }
}