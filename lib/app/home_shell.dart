import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../core/layout/responsive.dart';
import '../core/widgets/premium_ui.dart';
import '../core/widgets/responsive_frame.dart';
import '../features/comprehension/screens/test_list_screen.dart';
import '../features/oral/screens/oral_test_list_screen.dart';
import '../features/resources/pdf_library_screen.dart';
import '../features/settings/settings_screen.dart';
import '../l10n/app_localizations.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    TestListScreen(),
    OralTestListScreen(),
    PdfLibraryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final useRail = kIsWeb
        ? Responsive.isTabletWeb(context)
        : Responsive.isSplitLayout(context);

    if (useRail) {
      final railExtended = Responsive.width(context) >= 1100;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: railExtended,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              // Flutter assertion on web:
              // `!extended || (labelType == null || labelType == NavigationRailLabelType.none)`
              // So when `extended` is true, we must use `none` (or null) for `labelType`.
              labelType:
                  railExtended ? NavigationRailLabelType.none : NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: Text('Écrite'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.headphones_outlined),
                  selectedIcon: Icon(Icons.headphones_rounded),
                  label: Text('Orale'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.picture_as_pdf_outlined),
                  selectedIcon: Icon(Icons.picture_as_pdf_rounded),
                  label: Text('PDF'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Parametres'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Column(
                children: [
                  const _BrandHeader(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ResponsiveFrame(
                      expandToViewport: true,
                      child: IndexedStack(index: _index, children: _pages),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _BrandHeader(),
            const SizedBox(height: 12),
            Expanded(child: IndexedStack(index: _index, children: _pages)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: "Écrite",
          ),
          NavigationDestination(
            icon: Icon(Icons.headphones_outlined),
            selectedIcon: Icon(Icons.headphones_rounded),
            label: "Orale",
          ),
          NavigationDestination(
            icon: Icon(Icons.picture_as_pdf_outlined),
            selectedIcon: Icon(Icons.picture_as_pdf_rounded),
            label: "PDF",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: "Parametres",
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            PremiumBrandMark(
              heroTag: 'home_brand',
              large: false,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
