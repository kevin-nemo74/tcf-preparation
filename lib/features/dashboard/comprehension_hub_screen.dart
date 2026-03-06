import 'package:flutter/material.dart';

import '../comprehension/screens/test_list_screen.dart';
import '../oral/screens/oral_test_list_screen.dart';
import '../settings/settings_screen.dart';

class ComprehensionHubScreen extends StatelessWidget {
  const ComprehensionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 900;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Header Row (CE style) =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TCF Canada Preparation",
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Mock tests • Score / 699 • Review answers",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: cs.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: "Settings",
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ===== Tabs =====
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: cs.surfaceContainerHighest.withOpacity(0.55),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.35),
                    ),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: cs.primaryContainer.withOpacity(0.75),
                    ),
                    labelColor: cs.onPrimaryContainer,
                    unselectedLabelColor: cs.onSurface.withOpacity(0.7),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                    tabs: const [
                      Tab(icon: Icon(Icons.menu_book_rounded), text: "Écrite"),
                      Tab(icon: Icon(Icons.headphones_rounded), text: "Orale"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ===== Content =====
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        border: Border.all(
                          color: cs.outlineVariant.withOpacity(0.25),
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TabBarView(
                        physics: isWide
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        children: const [
                          // These screens should NOT have their own AppBars
                          TestListScreen(showHeader: false),
                          OralTestListScreen(),
                        ],
                      ),
                    ),
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
