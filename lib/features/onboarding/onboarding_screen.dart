import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';

class OnboardingScreen extends StatefulWidget {
  final Widget child;
  const OnboardingScreen({super.key, required this.child});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _pages = [
    (
      title: 'How scoring works',
      body: 'Each test is scored on a 699-point scale and mapped to NCLC bands.'
    ),
    (
      title: 'Study rhythm',
      body: 'Use daily tasks from your study plan and keep your streak alive.'
    ),
    (
      title: 'Track your progress',
      body: 'See best score, recent attempts, weak areas, and review queue.'
    ),
  ];

  Future<void> _finish() async {
    await ProgressRepository.setOnboardingDone();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.width(context) < Responsive.breakpointMedium
                  ? Responsive.width(context)
                  : 560,
            ),
            child: Padding(
              padding: Responsive.pagePadding(context, vertical: 20),
              child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final page = _pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == 0
                              ? Icons.insights_rounded
                              : i == 1
                                  ? Icons.today_rounded
                                  : Icons.trending_up_rounded,
                          size: 72,
                          color: cs.primary,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.72),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: i == _index ? cs.primary : cs.outlineVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_index == _pages.length - 1) {
                      _finish();
                      return;
                    }
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Text(_index == _pages.length - 1 ? 'Start' : 'Next'),
                ),
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
