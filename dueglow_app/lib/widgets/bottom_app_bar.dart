import '../screens/add_product_screen.dart';
import '../screens/my_products_screen.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/routines_screen.dart';
import '../l10n/app_localizations.dart';
import '../models/app_tutorial_step.dart';
import '../models/tutorial_launch.dart';
import '../services/onboarding_service.dart';
import 'app_tutorial_overlay.dart';
import 'tutorial_bottom_nav_bar.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  final Widget? child;
  final List<BottomNavigationBarItem>? items;
  final bool showLabels;
  final TutorialLaunch? tutorialLaunch;

  const BottomNavBar({
    super.key,
    this.initialIndex = 0,
    this.child,
    this.items,
    this.showLabels = true,
    this.tutorialLaunch,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;
  late List<Widget> _screens;

  bool _tutorialVisible = false;
  int _tutorialStepIndex = 0;
  late final List<AppTutorialStep> _tutorialSteps;
  late final List<GlobalKey> _tabKeys;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = const [
      HomeScreen(),
      MyProductsScreen(),
      AddProductScreen(),
      RoutinesScreen(),
      ProfileScreen(),
    ];
    _tutorialSteps = AppTutorialStep.all();
    _tabKeys = List.generate(5, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTutorial());
  }

  Future<void> _maybeStartTutorial() async {
    final launch = widget.tutorialLaunch;
    var show = false;

    if (launch == TutorialLaunch.newUser || launch == TutorialLaunch.replay) {
      show = true;
    } else {
      show = !(await OnboardingService.isCompleted());
    }

    if (!mounted || !show) return;

    setState(() {
      _tutorialStepIndex = 0;
      _tutorialVisible = true;
      _applyTutorialTab(_tutorialSteps[0]);
    });
  }

  void _applyTutorialTab(AppTutorialStep step) {
    final tab = step.tabIndex;
    if (tab != null) {
      _currentIndex = tab;
    }
  }

  Future<void> _finishTutorial() async {
    await OnboardingService.markCompleted();
    if (!mounted) return;
    setState(() => _tutorialVisible = false);
  }

  void _tutorialNext() {
    final isLast = _tutorialStepIndex >= _tutorialSteps.length - 1;
    if (isLast) {
      _finishTutorial();
      return;
    }
    setState(() {
      _tutorialStepIndex++;
      _applyTutorialTab(_tutorialSteps[_tutorialStepIndex]);
    });
  }

  void _tutorialBack() {
    if (_tutorialStepIndex <= 0) return;
    setState(() {
      _tutorialStepIndex--;
      _applyTutorialTab(_tutorialSteps[_tutorialStepIndex]);
    });
  }

  void _onTap(int index) {
    if (_tutorialVisible) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final unselectedColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.1);

    final defaultItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: l10n.home,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag_outlined),
        activeIcon: Icon(Icons.shopping_bag),
        label: l10n.products,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add),
        activeIcon: Icon(Icons.add),
        label: l10n.newTab,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.access_time),
        activeIcon: Icon(Icons.access_time_filled),
        label: l10n.routines,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.category_outlined),
        activeIcon: Icon(Icons.category),
        label: l10n.categories,
      ),
    ];

    final navItems = widget.items ?? defaultItems;
    final body = widget.child ?? _screens[_currentIndex];
    final step = _tutorialVisible ? _tutorialSteps[_tutorialStepIndex] : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          body: body,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: TutorialBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onTap,
              items: navItems,
              tabKeys: _tabKeys,
              selectedColor: theme.colorScheme.primary,
              unselectedColor: unselectedColor,
              backgroundColor: theme.colorScheme.surface,
              showLabels: widget.showLabels,
            ),
          ),
        ),
        if (_tutorialVisible && step != null)
          AppTutorialOverlay(
            currentStep: _tutorialStepIndex,
            totalSteps: _tutorialSteps.length,
            title: step.title(l10n),
            body: step.body(l10n),
            icon: step.icon,
            tabKeys: _tabKeys,
            highlightTabIndex:
                step.highlightNavTab ? step.tabIndex : null,
            contentTargetIds: step.contentTargetIds,
            showBack: _tutorialStepIndex > 0,
            isLast: _tutorialStepIndex == _tutorialSteps.length - 1,
            onNext: _tutorialNext,
            onBack: _tutorialBack,
            onSkip: _finishTutorial,
          ),
      ],
    );
  }
}
