import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final Widget child;
  const OnboardingScreen({super.key, required this.child});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  Future<void> _finish() async {
    await ProgressRepository.setOnboardingDone();
    await AppAnalytics.logOnboardingCompleted();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isWebLayout =
        Responsive.width(context) >= Responsive.tabletWebBreakpoint;
    final pages = [
      (
        title: l10n.onboardingHowScoringTitle,
        body: l10n.onboardingHowScoringBody,
      ),
      (
        title: l10n.onboardingStudyRhythmTitle,
        body: l10n.onboardingStudyRhythmBody,
      ),
      (title: l10n.onboardingProgressTitle, body: l10n.onboardingProgressBody),
    ];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primaryContainer.withValues(alpha: 0.2),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    Responsive.width(context) < Responsive.breakpointMedium
                    ? Responsive.width(context)
                    : 560,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isWebLayout ? 28 : 20,
                  24,
                  isWebLayout ? 28 : 20,
                  24,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primaryContainer.withValues(alpha: 0.5),
                            cs.secondaryContainer.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              size: 22,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'TCF Canada',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: pages.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (_, i) {
                          final page = pages[i];
                          return Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: cs.primary.withValues(alpha: 0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.08),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        cs.primaryContainer.withValues(
                                          alpha: 0.5,
                                        ),
                                        cs.secondaryContainer.withValues(
                                          alpha: 0.3,
                                        ),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.primary.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    i == 0
                                        ? Icons.insights_rounded
                                        : i == 1
                                        ? Icons.today_rounded
                                        : Icons.trending_up_rounded,
                                    size: 52,
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  page.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  page.body,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cs.onSurface.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: i == _index ? 32 : 12,
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: i == _index
                                ? LinearGradient(
                                    colors: [cs.primary, cs.secondary],
                                  )
                                : null,
                            color: i == _index ? null : cs.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: () {
                          if (_index == pages.length - 1) {
                            _finish();
                            return;
                          }
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _index == pages.length - 1
                                  ? l10n.onboardingStart
                                  : l10n.onboardingNext,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _index == pages.length - 1
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _finish,
                      child: Text(l10n.onboardingSkip),
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
