import 'package:flutter/material.dart';
import '../widgets/main_toolbar.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../models/tutorial_launch.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  static List<_FaqEntry> _faqEntries(AppLocalizations l10n) => [
        _FaqEntry(l10n.faqWhatIsAppQ, l10n.faqWhatIsAppA),
        _FaqEntry(l10n.faqAddProductQ, l10n.faqAddProductA),
        _FaqEntry(l10n.faqExpirationQ, l10n.faqExpirationA),
        _FaqEntry(l10n.faqProductListsQ, l10n.faqProductListsA),
        _FaqEntry(l10n.faqRoutinesQ, l10n.faqRoutinesA),
        _FaqEntry(l10n.faqScanNotFoundQ, l10n.faqScanNotFoundA),
        _FaqEntry(l10n.faqExpiringSoonQ, l10n.faqExpiringSoonA),
        _FaqEntry(l10n.faqOpenFinishQ, l10n.faqOpenFinishA),
        _FaqEntry(l10n.faqSettingsLangQ, l10n.faqSettingsLangA),
        _FaqEntry(l10n.faqDeleteAccountQ, l10n.faqDeleteAccountA),
      ];

  void _replayTutorial(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppConstants.routeHome,
      (route) => false,
      arguments: TutorialLaunch.replay,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final entries = _faqEntries(l10n);

    return CustomAppBar(
      title: l10n.faqs,
      showDrawer: true,
      showBackButton: true,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: entries.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _TutorialReplayCard(
              theme: theme,
              l10n: l10n,
              onPressed: () => _replayTutorial(context),
            );
          }
          return _FaqTile(entry: entries[index - 1], theme: theme);
        },
      ),
    );
  }
}

class _TutorialReplayCard extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  const _TutorialReplayCard({
    required this.theme,
    required this.l10n,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.school_outlined, color: theme.colorScheme.primary, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tutorialReplayTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.tutorialReplaySubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqEntry {
  final String question;
  final String answer;

  const _FaqEntry(this.question, this.answer);
}

class _FaqTile extends StatelessWidget {
  final _FaqEntry entry;
  final ThemeData theme;

  const _FaqTile({
    required this.entry,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final subtleText = theme.colorScheme.onSurface.withValues(alpha: 0.75);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.primary,
        title: Text(
          entry.question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            height: 1.35,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              entry.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: subtleText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
