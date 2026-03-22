import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import 'package:tcf_canada_preparation/features/comprehension/screens/test_list_screen.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';

import '../oral/screens/oral_test_list_screen.dart';
import '../settings/settings_screen.dart';
import 'study_plan_portal_card.dart';

class ExamPortalScreen extends StatelessWidget {
  const ExamPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = ProgressRepository.currentUid;
    final wide = Responsive.isSplitLayout(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("TCF Canada Simulator"),
          actions: [
            IconButton(
              tooltip: "Settings",
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  AppRoutes.fadeSlide(const SettingsScreen()),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 52,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
                ),
                child: TabBar(
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorAnimation: TabIndicatorAnimation.elastic,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: cs.primaryContainer.withValues(alpha: 0.75),
                  ),
                  labelColor: cs.onPrimaryContainer,
                  unselectedLabelColor: cs.onSurface.withValues(alpha: 0.75),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.menu_book_rounded, size: 18),
                      text: "Écrite",
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                    Tab(
                      icon: Icon(Icons.headphones_rounded, size: 18),
                      text: "Orale",
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: Responsive.horizontalInset(context),
          child: ResponsiveFrame(
            child: Column(
              children: [
            if (uid != null)
              Padding(
                padding: EdgeInsets.fromLTRB(16, wide ? 6 : 12, 16, wide ? 2 : 4),
                child: StreamBuilder<UserProgressSummary>(
                  stream: ProgressRepository.streamSummary(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return ShimmerSkeleton(
                        height: wide ? 64 : 76,
                        borderRadius: 14,
                      );
                    }
                    final summary = snapshot.data ?? UserProgressSummary.empty();
                    return AnimatedFadeSlide(
                      duration: AppMotion.fast,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: wide ? 10 : 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 8,
                          children: [
                            _Kpi(label: 'Best', value: '${summary.bestScore} / 699'),
                            _Kpi(label: 'Last', value: '${summary.lastScore} / 699'),
                            _Kpi(label: 'Attempts', value: '${summary.attemptsCount}'),
                            _Kpi(label: 'Streak', value: '${summary.currentStreak} d'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (uid != null) StudyPlanPortalCard(uid: uid),
            const Expanded(
              child: TabBarView(
                children: [
                  TestListScreen(showHeader: false),
                  OralTestListScreen(),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  const _Kpi({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.68), fontSize: 12),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
