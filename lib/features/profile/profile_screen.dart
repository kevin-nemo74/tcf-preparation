import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/features/progress/review_queue_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
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
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }

          final data = snapshot.data?.data() ?? {};
          final username =
              (data['username'] ??
                      FirebaseAuth.instance.currentUser?.displayName ??
                      "Utilisateur")
                  .toString();
          final email =
              (data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? "")
                  .toString();

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
          final bestScore = _readInt(data, const ['bestScore', 'highestScore']);
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
                constraints: BoxConstraints(
                  maxWidth: Responsive.canvasMaxWidth(context),
                ),
                child: ListView(
                  padding: Responsive.pagePadding(context, vertical: 16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primaryContainer.withValues(alpha: 0.4),
                            cs.secondaryContainer.withValues(alpha: 0.25),
                          ],
                        ),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [cs.primary, cs.secondary],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: cs.primaryContainer,
                              child: Icon(
                                Icons.person_rounded,
                                color: cs.onPrimaryContainer,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_rounded,
                                      size: 14,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        email,
                                        style: TextStyle(
                                          color: cs.onSurface.withOpacity(0.75),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
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
                      title: "Nom d'utilisateur",
                      value: username,
                    ),
                    _InfoTile(
                      icon: Icons.email_rounded,
                      title: "E-mail",
                      value: email,
                    ),
                    _InfoTile(
                      icon: Icons.calendar_month_rounded,
                      title: "Date de creation",
                      value: createdAt == null ? "—" : _fmt(createdAt),
                    ),
                    _InfoTile(
                      icon: Icons.login_rounded,
                      title: "Derniere connexion",
                      value: lastLoginAt == null ? "—" : _fmt(lastLoginAt),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Progression",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _StatsTile(
                      icon: Icons.checklist_rounded,
                      title: "Tentatives totales",
                      value: attemptsCount?.toString() ?? "0",
                    ),
                    _StatsTile(
                      icon: Icons.emoji_events_rounded,
                      title: "Meilleur score",
                      value: bestScore == null ? "— / 699" : "$bestScore / 699",
                    ),
                    _StatsTile(
                      icon: Icons.history_rounded,
                      title: "Derniere tentative",
                      value: latestAttemptAt == null
                          ? "—"
                          : _fmt(latestAttemptAt),
                    ),
                    _StatsTile(
                      icon: Icons.local_fire_department_rounded,
                      title: "Serie en cours",
                      value: "$currentStreak jour(s)",
                    ),
                    _StatsTile(
                      icon: Icons.workspace_premium_rounded,
                      title: "Meilleure serie",
                      value: "$bestStreak jour(s)",
                    ),
                    _StatsTile(
                      icon: Icons.date_range_rounded,
                      title: "Cette semaine",
                      value:
                          "$weeklyAttempts tentatives • ${weeklyAverage.toStringAsFixed(1)} moy",
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Objectifs atteints",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _BadgeChip(
                          label: "Premiere tentative",
                          unlocked: (attemptsCount ?? 0) >= 1,
                        ),
                        _BadgeChip(
                          label: "5 tentatives",
                          unlocked: (attemptsCount ?? 0) >= 5,
                        ),
                        _BadgeChip(
                          label: "Score 500+",
                          unlocked: (bestScore ?? 0) >= 500,
                        ),
                        _BadgeChip(
                          label: "Serie 7 jours",
                          unlocked: currentStreak >= 7,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    StreamBuilder<List<ReviewQueueItem>>(
                      stream: ProgressRepository.streamReviewQueue(
                        uid,
                        limit: 20,
                      ),
                      builder: (context, qSnap) {
                        final items = qSnap.data ?? const <ReviewQueueItem>[];
                        return Column(
                          children: [
                            _StatsTile(
                              icon: Icons.assignment_late_rounded,
                              title: "File de revision",
                              value: "${items.length} question(s) a revoir",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AppRoutes.fadeSlide(
                                    ReviewQueueScreen(uid: uid),
                                  ),
                                );
                              },
                            ),
                            if (items.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Derniere en file: ${items.first.testTitle} / ${items.first.questionId}",
                                    style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Tentatives recentes",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: ProgressRepository.streamRecentAttempts(
                        uid,
                        limit: 6,
                      ),
                      builder: (context, attemptSnap) {
                        final attempts =
                            attemptSnap.data ?? const <Map<String, dynamic>>[];
                        if (attempts.isEmpty) {
                          return _StatsTile(
                            icon: Icons.history_rounded,
                            title: "Tentatives recentes",
                            value: "Aucune tentative pour le moment",
                          );
                        }
                        final ceAverage = _moduleAverage(attempts, 'CE');
                        final coAverage = _moduleAverage(attempts, 'CO');
                        return Column(
                          children: [
                            _StatsTile(
                              icon: Icons.analytics_rounded,
                              title: "Moyennes par module",
                              value:
                                  "CE ${ceAverage.toStringAsFixed(1)} / CO ${coAverage.toStringAsFixed(1)}",
                            ),
                            ...attempts
                                .take(4)
                                .map(
                                  (attempt) => _AttemptTile(attempt: attempt),
                                ),
                          ],
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
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.6),
                  cs.secondaryContainer.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.75),
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
  final VoidCallback? onTap;

  const _StatsTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: cs.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  final Map<String, dynamic> attempt;

  const _AttemptTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final module = (attempt['moduleType'] ?? 'CE').toString();
    final title =
        (attempt['testTitle'] ?? attempt['testId'] ?? 'Serie pratique')
            .toString();
    final score = _readAttemptScore(attempt);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.6),
                  cs.secondaryContainer.withValues(alpha: 0.4),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              module,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: cs.primary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$score / 699',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: cs.primary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double _moduleAverage(List<Map<String, dynamic>> attempts, String moduleType) {
  final filtered = attempts
      .where(
        (attempt) => (attempt['moduleType'] ?? 'CE').toString() == moduleType,
      )
      .toList();
  if (filtered.isEmpty) return 0;
  final total = filtered.fold<double>(
    0,
    (sum, attempt) => sum + _readAttemptScore(attempt),
  );
  return total / filtered.length;
}

int _readAttemptScore(Map<String, dynamic> attempt) {
  final value = attempt['score'];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final bool unlocked;

  const _BadgeChip({required this.label, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: unlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.6),
                  cs.secondaryContainer.withValues(alpha: 0.4),
                ],
              )
            : null,
        color: unlocked
            ? null
            : cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border.all(
          color: unlocked
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
            size: 16,
            color: unlocked ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: unlocked
                  ? cs.onPrimaryContainer
                  : cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
