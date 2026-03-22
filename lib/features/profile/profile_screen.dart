import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ShimmerSkeleton(height: 100),
                SizedBox(height: 14),
                ShimmerSkeleton(height: 64),
                SizedBox(height: 10),
                ShimmerSkeleton(height: 64),
                SizedBox(height: 10),
                ShimmerSkeleton(height: 64),
                SizedBox(height: 10),
                ShimmerSkeleton(height: 64),
              ],
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data?.data() ?? {};
          final username = (data['username'] ?? FirebaseAuth.instance.currentUser?.displayName ?? "User").toString();
          final email = (data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? "").toString();

          DateTime? createdAt;
          final created = data['createdAt'];
          if (created is Timestamp) createdAt = created.toDate();

          DateTime? lastLoginAt;
          final lastLogin = data['lastLoginAt'];
          if (lastLogin is Timestamp) lastLoginAt = lastLogin.toDate();

          final attemptsCount = _readInt(data, const [
            'attemptsCount',
            'attempts',
            'totalAttempts',
          ]);
          final bestScore = _readInt(data, const [
            'bestScore',
            'highestScore',
          ]);
          final latestAttemptAt = _readDate(data, const [
            'lastAttemptAt',
            'latestAttemptAt',
          ]);
          final currentStreak = _readInt(data, const ['currentStreak']) ?? 0;
          final bestStreak = _readInt(data, const ['bestStreak']) ?? 0;
          final weeklyAttempts = _readInt(data, const ['weeklyAttempts']) ?? 0;
          final weeklyAverage = _readDouble(data, const ['weeklyAverage']) ?? 0;

          return AnimatedFadeSlide(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Responsive.canvasMaxWidth(context)),
                child: ListView(
                  padding: Responsive.pagePadding(context, vertical: 16),
                  children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: cs.surface,
                    border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: cs.primaryContainer.withOpacity(0.7),
                        child: Icon(Icons.person_rounded, color: cs.onPrimaryContainer, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.65),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              _InfoTile(
                icon: Icons.badge_rounded,
                title: "Username",
                value: username,
              ),
              _InfoTile(
                icon: Icons.email_rounded,
                title: "Email",
                value: email,
              ),
              _InfoTile(
                icon: Icons.calendar_month_rounded,
                title: "Created",
                value: createdAt == null ? "—" : _fmt(createdAt),
              ),
              _InfoTile(
                icon: Icons.login_rounded,
                title: "Last login",
                value: lastLoginAt == null ? "—" : _fmt(lastLoginAt),
              ),

              const SizedBox(height: 20),
              Text(
                "Progress",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              _StatsTile(
                icon: Icons.checklist_rounded,
                title: "Total attempts",
                value: attemptsCount?.toString() ?? "0",
              ),
              _StatsTile(
                icon: Icons.emoji_events_rounded,
                title: "Best score",
                value: bestScore == null ? "— / 699" : "$bestScore / 699",
              ),
              _StatsTile(
                icon: Icons.history_rounded,
                title: "Latest attempt",
                value: latestAttemptAt == null ? "—" : _fmt(latestAttemptAt),
              ),
              _StatsTile(
                icon: Icons.local_fire_department_rounded,
                title: "Current streak",
                value: "$currentStreak day(s)",
              ),
              _StatsTile(
                icon: Icons.workspace_premium_rounded,
                title: "Best streak",
                value: "$bestStreak day(s)",
              ),
              _StatsTile(
                icon: Icons.date_range_rounded,
                title: "This week",
                value: "$weeklyAttempts attempts • ${weeklyAverage.toStringAsFixed(1)} avg",
              ),
              const SizedBox(height: 18),
              Text(
                "Milestones",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _BadgeChip(label: "First attempt", unlocked: (attemptsCount ?? 0) >= 1),
                  _BadgeChip(label: "5 attempts", unlocked: (attemptsCount ?? 0) >= 5),
                  _BadgeChip(label: "Best 500+", unlocked: (bestScore ?? 0) >= 500),
                  _BadgeChip(label: "7-day streak", unlocked: currentStreak >= 7),
                ],
              ),
              const SizedBox(height: 18),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: ProgressRepository.streamReviewQueue(uid, limit: 20),
                builder: (context, qSnap) {
                  final count = qSnap.data?.length ?? 0;
                  return _StatsTile(
                    icon: Icons.assignment_late_rounded,
                    title: "Review queue",
                    value: "$count question(s) to revisit",
                  );
                },
              ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _fmt(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  static int? _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  static DateTime? _readDate(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
    }
    return null;
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: cs.primaryContainer.withOpacity(0.6),
            ),
            child: Icon(icon, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatsTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final bool unlocked;

  const _BadgeChip({required this.label, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: unlocked
            ? cs.primaryContainer.withOpacity(0.6)
            : cs.surfaceContainerHighest.withOpacity(0.35),
        border: Border.all(
          color: unlocked ? cs.primary.withOpacity(0.5) : cs.outlineVariant.withOpacity(0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
            size: 16,
            color: unlocked ? cs.primary : cs.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: unlocked ? cs.onPrimaryContainer : cs.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
