import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/features/progress/study_plan_generator.dart';
import 'package:tcf_canada_preparation/features/progress/study_plan_screen.dart';

/// Collapsible study plan for the exam portal, collapsed by default on wide
/// layouts so the practice lists keep vertical space.
class StudyPlanPortalCard extends StatefulWidget {
  const StudyPlanPortalCard({super.key, required this.uid});

  final String uid;

  @override
  State<StudyPlanPortalCard> createState() => _StudyPlanPortalCardState();
}

class _StudyPlanPortalCardState extends State<StudyPlanPortalCard> {
  @override
  void initState() {
    super.initState();
    _refreshIfNeeded();
  }

  Future<void> _refreshIfNeeded() async {
    await ProgressRepository.refreshStudyPlanIfNeeded(
      widget.uid,
      rebuild: (existingPlan) async {
        final attempts =
            await ProgressRepository.streamRecentAttempts(widget.uid, limit: 20).first;
        final reviewQueue =
            await ProgressRepository.streamReviewQueue(widget.uid, limit: 100).first;
        return StudyPlanGenerator.generate(
          targetScore: existingPlan.targetScore,
          targetLevel: existingPlan.targetLevel,
          targetDate: existingPlan.targetDate,
          weeklyCadence: existingPlan.weeklyCadence,
          recentAttempts: attempts,
          pendingReviewCount: reviewQueue.length,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final wide = Responsive.isSplitLayout(context);
    final taskMaxHeight = wide ? 180.0 : 260.0;

    return StreamBuilder<StudyPlan?>(
      stream: ProgressRepository.streamStudyPlan(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ShimmerSkeleton(height: 52, borderRadius: 16),
          );
        }
        final plan = snapshot.data;
        final hasPlan = plan != null;
        final doneCount = hasPlan ? plan.todayTasks.where((t) => t.done).length : 0;
        final totalTasks = hasPlan ? plan.todayTasks.length : 0;
        final subtitleText = !hasPlan
            ? 'Definissez un score cible et des taches quotidiennes - ouvrez pour details'
            : 'Objectif ${plan.targetScore} (${plan.targetLevel}) - $doneCount/$totalTasks realisees aujourd\'hui';

        return Padding(
          padding: EdgeInsets.fromLTRB(16, wide ? 2 : 4, 16, wide ? 4 : 8),
          child: Material(
            color: cs.surface,
            elevation: 0,
            shadowColor: cs.shadow.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: kIsWeb ? false : !wide,
                maintainState: true,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                shape: const RoundedRectangleBorder(),
                collapsedShape: const RoundedRectangleBorder(),
                title: Row(
                  children: [
                    Icon(Icons.event_note_rounded, size: 20, color: cs.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Plan d\'etude',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppRoutes.fadeSlide(const StudyPlanScreen()),
                        );
                      },
                      child: Text(hasPlan ? 'Modifier' : 'Configurer'),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: Text(
                    subtitleText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                children: [
                  if (!hasPlan)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Ouvrez la configuration pour choisir le niveau NCLC, la date cible et le rythme hebdomadaire. Les taches s\'affichent ici chaque jour.',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  if (hasPlan && StudyPlanGenerator.needsRefresh(plan))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Ce plan a ete genere pour un jour precedent. Ouvrez la configuration pour actualiser les taches du jour.',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (hasPlan)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: taskMaxHeight),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: plan.todayTasks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 2),
                        itemBuilder: (context, i) {
                          final task = plan.todayTasks[i];
                          return CheckboxListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: task.done,
                            title: Text(
                              task.title,
                              style: const TextStyle(fontSize: 13.5),
                            ),
                            onChanged: (_) async {
                              await ProgressRepository.toggleTask(
                                widget.uid,
                                task.id,
                              );
                              await AppAnalytics.logStudyPlanTaskToggled(
                                done: !task.done,
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
