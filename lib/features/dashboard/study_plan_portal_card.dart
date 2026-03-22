import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/features/progress/study_plan_screen.dart';

/// Collapsible study plan for the exam portal — **collapsed by default** on wide /
/// split layouts (typical web) so test lists keep vertical space.
class StudyPlanPortalCard extends StatefulWidget {
  const StudyPlanPortalCard({super.key, required this.uid});

  final String uid;

  @override
  State<StudyPlanPortalCard> createState() => _StudyPlanPortalCardState();
}

class _StudyPlanPortalCardState extends State<StudyPlanPortalCard> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final wide = Responsive.isSplitLayout(context);
    final taskMaxHeight = wide ? 180.0 : 260.0;

    return StreamBuilder<StudyPlan?>(
      stream: ProgressRepository.streamStudyPlan(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ShimmerSkeleton(height: 52, borderRadius: 16),
          );
        }
        final plan = snapshot.data;
        final hasPlan = plan != null;
        final doneCount = hasPlan ? plan.todayTasks.where((t) => t.done).length : 0;
        final totalTasks = hasPlan ? plan.todayTasks.length : 0;

        String subtitleText;
        if (!hasPlan) {
          subtitleText = 'Set a target score and daily tasks — expand for details';
        } else {
          subtitleText =
              'Target ${plan.targetScore} (${plan.targetLevel}) · $doneCount/$totalTasks done today';
        }

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
                // Web: start collapsed so test lists get height; mobile app: expand on narrow.
                initiallyExpanded: kIsWeb ? false : !wide,
                maintainState: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                shape: const RoundedRectangleBorder(),
                collapsedShape: const RoundedRectangleBorder(),
                title: Row(
                  children: [
                    Icon(Icons.event_note_rounded, size: 20, color: cs.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Study Plan',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppRoutes.fadeSlide(const StudyPlanScreen()),
                        );
                      },
                      child: Text(hasPlan ? 'Edit' : 'Setup'),
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
                        'Open Setup to choose your target NCLC band, test date, and weekly rhythm. '
                        'Tasks appear here each day.',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  if (hasPlan) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: taskMaxHeight),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: plan.todayTasks.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 2),
                        itemBuilder: (context, i) {
                          final t = plan.todayTasks[i];
                          return CheckboxListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: t.done,
                            title: Text(t.title, style: const TextStyle(fontSize: 13.5)),
                            onChanged: (_) =>
                                ProgressRepository.toggleTask(widget.uid, t.id),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
