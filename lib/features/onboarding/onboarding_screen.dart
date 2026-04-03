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
              cs.primaryContainer.withValues(alpha: 0.18),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.12),
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
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 20,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TCF Canada',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: pages.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (_, i) {
                          final page = pages[i];
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.shadow.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer.withValues(
                                      alpha: 0.3,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    i == 0
                                        ? Icons.insights_rounded
                                        : i == 1
                                        ? Icons.today_rounded
                                        : Icons.trending_up_rounded,
                                    size: 48,
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  page.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  page.body,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cs.onSurface.withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: i == _index ? cs.primary : cs.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          if (_index == pages.length - 1) {
                            _finish();
                            return;
                          }
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Text(
                          _index == pages.length - 1
                              ? l10n.onboardingStart
                              : l10n.onboardingNext,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
