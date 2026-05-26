import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AppTutorialStep {
  final int? tabIndex;
  final IconData icon;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) body;

  /// Widget ids registered via [TutorialTarget] on the active screen.
  final List<String> contentTargetIds;

  /// When false, navigates to [tabIndex] but does not spotlight the bottom tab.
  final bool highlightNavTab;

  const AppTutorialStep({
    this.tabIndex,
    required this.icon,
    required this.title,
    required this.body,
    this.contentTargetIds = const [],
    this.highlightNavTab = true,
  });

  static List<AppTutorialStep> all() => [
        const AppTutorialStep(
          tabIndex: 0,
          icon: Icons.spa_outlined,
          highlightNavTab: false,
          title: _welcomeTitle,
          body: _welcomeBody,
        ),
        const AppTutorialStep(
          tabIndex: 0,
          icon: Icons.home_outlined,
          contentTargetIds: ['home_routine', 'home_expiring'],
          title: _homeTitle,
          body: _homeBody,
        ),
        const AppTutorialStep(
          tabIndex: 1,
          icon: Icons.shopping_bag_outlined,
          contentTargetIds: ['products_lists'],
          title: _productsTitle,
          body: _productsBody,
        ),
        const AppTutorialStep(
          tabIndex: 2,
          icon: Icons.add_circle_outline,
          contentTargetIds: ['add_shortcuts'],
          title: _newTitle,
          body: _newBody,
        ),
        const AppTutorialStep(
          tabIndex: 3,
          icon: Icons.access_time,
          contentTargetIds: ['routines_tabs'],
          title: _routinesTitle,
          body: _routinesBody,
        ),
        const AppTutorialStep(
          tabIndex: 4,
          icon: Icons.category_outlined,
          contentTargetIds: ['vanity_tabs'],
          title: _vanityTitle,
          body: _vanityBody,
        ),
        const AppTutorialStep(
          tabIndex: 0,
          icon: Icons.menu,
          highlightNavTab: false,
          contentTargetIds: ['app_menu'],
          title: _drawerTitle,
          body: _drawerBody,
        ),
        const AppTutorialStep(
          tabIndex: 0,
          icon: Icons.check_circle_outline,
          highlightNavTab: false,
          title: _doneTitle,
          body: _doneBody,
        ),
      ];

  static String _welcomeTitle(AppLocalizations l10n) => l10n.tutorialWelcomeTitle;
  static String _welcomeBody(AppLocalizations l10n) => l10n.tutorialWelcomeBody;
  static String _homeTitle(AppLocalizations l10n) => l10n.tutorialHomeTitle;
  static String _homeBody(AppLocalizations l10n) => l10n.tutorialHomeBody;
  static String _productsTitle(AppLocalizations l10n) => l10n.tutorialProductsTitle;
  static String _productsBody(AppLocalizations l10n) => l10n.tutorialProductsBody;
  static String _newTitle(AppLocalizations l10n) => l10n.tutorialNewTitle;
  static String _newBody(AppLocalizations l10n) => l10n.tutorialNewBody;
  static String _routinesTitle(AppLocalizations l10n) => l10n.tutorialRoutinesTitle;
  static String _routinesBody(AppLocalizations l10n) => l10n.tutorialRoutinesBody;
  static String _vanityTitle(AppLocalizations l10n) => l10n.tutorialVanityTitle;
  static String _vanityBody(AppLocalizations l10n) => l10n.tutorialVanityBody;
  static String _drawerTitle(AppLocalizations l10n) => l10n.tutorialDrawerTitle;
  static String _drawerBody(AppLocalizations l10n) => l10n.tutorialDrawerBody;
  static String _doneTitle(AppLocalizations l10n) => l10n.tutorialDoneTitle;
  static String _doneBody(AppLocalizations l10n) => l10n.tutorialDoneBody;
}
