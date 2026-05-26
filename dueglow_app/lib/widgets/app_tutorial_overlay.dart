import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../tutorial/tutorial_target_registry.dart';

/// Full-screen tutorial overlay with spotlight cutouts and glow borders.
class AppTutorialOverlay extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final bool showBack;
  final bool isLast;
  final int? highlightTabIndex;
  final List<String> contentTargetIds;
  final List<GlobalKey> tabKeys;

  const AppTutorialOverlay({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.body,
    required this.icon,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.showBack,
    required this.isLast,
    required this.tabKeys,
    this.highlightTabIndex,
    this.contentTargetIds = const [],
  });

  @override
  State<AppTutorialOverlay> createState() => _AppTutorialOverlayState();
}

class _AppTutorialOverlayState extends State<AppTutorialOverlay>
    with SingleTickerProviderStateMixin {
  List<RRect> _holes = [];
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(covariant AppTutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep ||
        oldWidget.highlightTabIndex != widget.highlightTabIndex ||
        oldWidget.contentTargetIds != widget.contentTargetIds) {
      _scheduleMeasure();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureTargets();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _measureTargets();
      });
    });
  }

  void _measureTargets() {
    final overlayBox = context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.hasSize) return;

    final measured = <RRect>[];

    void addRect(Rect global, {bool isNav = false}) {
      final local = Rect.fromPoints(
        overlayBox.globalToLocal(global.topLeft),
        overlayBox.globalToLocal(global.bottomRight),
      );
      final padding = isNav ? 4.0 : 8.0;
      final inflated = local.inflate(padding);
      measured.add(
        RRect.fromRectAndRadius(
          inflated,
          Radius.circular(isNav ? 16 : 14),
        ),
      );
    }

    if (widget.highlightTabIndex != null) {
      final index = widget.highlightTabIndex!;
      if (index >= 0 && index < widget.tabKeys.length) {
        final rect = _globalRect(widget.tabKeys[index]);
        if (rect != null) addRect(rect, isNav: true);
      }
    }

    for (final id in widget.contentTargetIds) {
      final rect = TutorialTargetRegistry.globalRect(id);
      if (rect != null) addRect(rect);
    }

    setState(() => _holes = measured);
  }

  Rect? _globalRect(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const navBarHeight = kBottomNavigationBarHeight;
    final cardBottom = navBarHeight + bottomInset + 20;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SpotlightPainter(
                    holes: _holes,
                    dimColor: Colors.black.withValues(alpha: 0.78),
                    borderColor: theme.colorScheme.primary,
                    pulse: 0.55 + _pulseController.value * 0.45,
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: cardBottom,
            child: _TutorialCard(
              theme: theme,
              l10n: l10n,
              currentStep: widget.currentStep,
              totalSteps: widget.totalSteps,
              title: widget.title,
              body: widget.body,
              icon: widget.icon,
              showBack: widget.showBack,
              isLast: widget.isLast,
              onNext: widget.onNext,
              onBack: widget.onBack,
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 12,
            child: TextButton(
              onPressed: widget.onSkip,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black.withValues(alpha: 0.35),
              ),
              child: Text(
                l10n.tutorialSkip,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final List<RRect> holes;
  final Color dimColor;
  final Color borderColor;
  final double pulse;

  _SpotlightPainter({
    required this.holes,
    required this.dimColor,
    required this.borderColor,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final background = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    for (final hole in holes) {
      background.addRRect(hole);
    }
    background.fillType = PathFillType.evenOdd;
    canvas.drawPath(background, Paint()..color = dimColor);

    for (final hole in holes) {
      canvas.drawRRect(
        hole,
        Paint()
          ..color = borderColor.withValues(alpha: pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawRRect(
        hole.inflate(5),
        Paint()
          ..color = borderColor.withValues(alpha: 0.18 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.holes != holes || oldDelegate.pulse != pulse;
  }
}

class _TutorialCard extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;
  final int currentStep;
  final int totalSteps;
  final String title;
  final String body;
  final IconData icon;
  final bool showBack;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _TutorialCard({
    required this.theme,
    required this.l10n,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.body,
    required this.icon,
    required this.showBack,
    required this.isLast,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tutorialStepOf(currentStep + 1, totalSteps),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(totalSteps, (i) {
                final active = i == currentStep;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (showBack)
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: Text(l10n.tutorialBack),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                FilledButton(
                  onPressed: onNext,
                  child: Text(isLast ? l10n.tutorialFinish : l10n.tutorialNext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
