import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../core/layout/responsive.dart';
import '../core/widgets/responsive_frame.dart';
import '../features/comprehension/screens/test_list_screen.dart';
import '../features/oral/screens/oral_test_list_screen.dart';
import '../features/settings/settings_screen.dart';

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
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final useRail = kIsWeb
        ? Responsive.isTabletWeb(context)
        : Responsive.isSplitLayout(context);

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: Responsive.width(context) >= 1100,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
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
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: ResponsiveFrame(
                expandToViewport: true,
                child: IndexedStack(index: _index, children: _pages),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
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
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
