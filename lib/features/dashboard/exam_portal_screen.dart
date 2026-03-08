import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/features/comprehension/screens/test_list_screen.dart';

import '../settings/settings_screen.dart';
import '../oral/screens/oral_test_list_screen.dart';

class ExamPortalScreen extends StatelessWidget {
  const ExamPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64), // ✅ more height
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 52, // ✅ increased from 42
                padding: const EdgeInsets.all(4), // ✅ smaller padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surfaceContainerHighest.withOpacity(0.55),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
                ),
                child: TabBar(
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: cs.primaryContainer.withOpacity(0.75),
                  ),
                  labelColor: cs.onPrimaryContainer,
                  unselectedLabelColor: cs.onSurface.withOpacity(0.75),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13, // ✅ slightly smaller
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.menu_book_rounded, size: 18), // ✅ smaller
                      text: "Écrite",
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                    Tab(
                      icon: Icon(Icons.headphones_rounded, size: 18), // ✅ smaller
                      text: "Orale",
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            TestListScreen(showHeader: false),
            OralTestListScreen(),
          ],
        ),
      ),
    );
  }
}