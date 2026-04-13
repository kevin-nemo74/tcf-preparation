import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../core/layout/responsive.dart';
import '../core/widgets/premium_ui.dart';
import '../core/widgets/responsive_frame.dart';
import '../features/admin/user_status_service.dart';
import '../features/comprehension/screens/test_list_screen.dart';
import '../features/dashboard/exam_portal_screen.dart';
import '../features/expression_ecrite/screens/ee_home_screen.dart';
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
  bool _isSuspended = false;
  bool _isLoading = true;
  Timer? _checkTimer;

  final List<Widget> _fullPages = const [
    TestListScreen(),
    OralTestListScreen(),
    EEHomeScreen(),
    PdfLibraryScreen(),
    ExamPortalScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkUserStatus(silent: true);
    });
  }

  Future<void> _checkUserStatus({bool silent = false}) async {
    final isSuspended = await UserStatusService.instance.checkIsSuspended();
    if (!mounted) return;

    final wasSuspended = _isSuspended;
    setState(() {
      _isSuspended = isSuspended;
      _isLoading = false;
    });

    if (!silent && wasSuspended && !isSuspended && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Votre compte a ete reactive. Vous avez de nouveau acces a tous les tests.',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onTabSelected(int index) {
    if (index < 5) {
      _checkUserStatusAndNavigate(index);
    } else {
      setState(() => _index = index);
    }
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Future<void> _checkUserStatusAndNavigate(int targetIndex) async {
    final isSuspended = await UserStatusService.instance.checkIsSuspended();
    if (!mounted) return;

    if (isSuspended) {
      setState(() => _isSuspended = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Votre compte est suspendu. Acces limite aux parametres.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSuspended = false;
      _index = targetIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isSuspended) {
      return _buildSuspendedLayout();
    }

    return _buildNormalLayout();
  }

  Widget _buildNormalLayout() {
    final useRail = kIsWeb
        ? Responsive.isTabletWeb(context)
        : Responsive.isSplitLayout(context);

    if (useRail) {
      return _buildWebLayout();
    }

    return _buildMobileLayout();
  }

  Widget _buildSuspendedLayout() {
    final cs = Theme.of(context).colorScheme;
    final useRail = kIsWeb
        ? Responsive.isTabletWeb(context)
        : Responsive.isSplitLayout(context);

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: null,
              onDestinationSelected: (_) {},
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined, color: cs.outline),
                  label: Text('CE', style: TextStyle(color: cs.outline)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.headphones_outlined, color: cs.outline),
                  label: Text('CO', style: TextStyle(color: cs.outline)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.edit_note_outlined, color: cs.outline),
                  label: Text('EE', style: TextStyle(color: cs.outline)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.picture_as_pdf_outlined, color: cs.outline),
                  label: Text('PDF', style: TextStyle(color: cs.outline)),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Icons.dashboard_customize_outlined,
                    color: cs.outline,
                  ),
                  label: Text('Tableau', style: TextStyle(color: cs.outline)),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Column(
                children: [
                  _BrandHeader(isSuspended: true),
                  const SizedBox(height: 12),
                  const Expanded(
                    child: ResponsiveFrame(
                      expandToViewport: true,
                      child: SettingsScreen(),
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
            _BrandHeader(isSuspended: true),
            const SizedBox(height: 12),
            const Expanded(child: SettingsScreen()),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: cs.outline),
            label: "CE",
          ),
          NavigationDestination(
            icon: Icon(Icons.headphones_outlined, color: cs.outline),
            label: "CO",
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined, color: cs.outline),
            label: "EE",
          ),
          NavigationDestination(
            icon: Icon(Icons.picture_as_pdf_outlined, color: cs.outline),
            label: "PDF",
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_customize_outlined, color: cs.outline),
            label: "Tableau",
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: Responsive.width(context) >= 1100,
            selectedIndex: _index,
            onDestinationSelected: _onTabSelected,
            labelType: Responsive.width(context) >= 1100
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: Text('CE'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.headphones_outlined),
                selectedIcon: Icon(Icons.headphones_rounded),
                label: Text('CO'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.edit_note_outlined),
                selectedIcon: Icon(Icons.edit_note_rounded),
                label: Text('EE'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.picture_as_pdf_outlined),
                selectedIcon: Icon(Icons.picture_as_pdf_rounded),
                label: Text('PDF'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_customize_outlined),
                selectedIcon: Icon(Icons.dashboard_customize_rounded),
                label: Text('Tableau'),
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
                    child: IndexedStack(index: _index, children: _fullPages),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _BrandHeader(onSettingsPressed: _openSettings),
            const SizedBox(height: 12),
            Expanded(
              child: IndexedStack(index: _index, children: _fullPages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: "CE",
          ),
          NavigationDestination(
            icon: Icon(Icons.headphones_outlined),
            selectedIcon: Icon(Icons.headphones_rounded),
            label: "CO",
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note_rounded),
            label: "EE",
          ),
          NavigationDestination(
            icon: Icon(Icons.picture_as_pdf_outlined),
            selectedIcon: Icon(Icons.picture_as_pdf_rounded),
            label: "PDF",
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_customize_outlined),
            selectedIcon: Icon(Icons.dashboard_customize_rounded),
            label: "Tableau",
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool isSuspended;
  final VoidCallback? onSettingsPressed;

  const _BrandHeader({this.isSuspended = false, this.onSettingsPressed});

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
          color: isSuspended
              ? cs.errorContainer.withValues(alpha: 0.3)
              : cs.surfaceContainerHighest.withValues(alpha: 0.42),
          border: Border.all(
            color: isSuspended
                ? cs.error.withValues(alpha: 0.3)
                : cs.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            PremiumBrandMark(heroTag: 'home_brand', large: false),
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
            if (isSuspended) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pause_circle_rounded, size: 14, color: cs.error),
                    const SizedBox(width: 4),
                    Text(
                      'Suspendu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: cs.error,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (onSettingsPressed != null) ...[
              IconButton(
                icon: Icon(Icons.settings_outlined, color: cs.onSurfaceVariant),
                onPressed: onSettingsPressed,
                tooltip: 'Parametres',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
