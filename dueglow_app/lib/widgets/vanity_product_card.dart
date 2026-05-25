import 'package:flutter/material.dart';
import '../models/beauty_product.dart';
import '../l10n/app_localizations.dart';

/// Tarjeta vertical para el tocador / categorías (distinto del listado de productos).
class VanityProductCard extends StatefulWidget {
  final BeautyProduct product;
  final VoidCallback? onTap;

  const VanityProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<VanityProductCard> createState() => _VanityProductCardState();
}

class _VanityProductCardState extends State<VanityProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final brand = widget.product.brand?.trim();
    final hasBrand = brand != null && brand.isNotEmpty;
    final hasExpiration = widget.product.expirationDate != null;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Material(
            color: theme.colorScheme.surface,
            elevation: isDark ? 0 : 3,
            shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _handleTap,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildImage(theme, isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hasBrand ? brand : l10n.noBrand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: hasBrand
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.45),
                              fontWeight: hasBrand
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontStyle:
                                  hasBrand ? FontStyle.normal : FontStyle.italic,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              fontSize: 13,
                            ),
                          ),
                          if (hasExpiration) ...[
                            const SizedBox(height: 6),
                            _buildExpirationChip(theme, l10n),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(ThemeData theme, bool isDark) {
    final imageBg = isDark
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
        : theme.colorScheme.primary.withValues(alpha: 0.06);

    return Container(
      width: double.infinity,
      color: imageBg,
      child: widget.product.imageUrl != null &&
              widget.product.imageUrl!.isNotEmpty
          ? Image.network(
              widget.product.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  _placeholderIcon(theme),
            )
          : _placeholderIcon(theme),
    );
  }

  Widget _placeholderIcon(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.spa_outlined,
        size: 36,
        color: theme.colorScheme.primary.withValues(alpha: 0.45),
      ),
    );
  }

  Widget _buildExpirationChip(ThemeData theme, AppLocalizations l10n) {
    final date = widget.product.expirationDate!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expDay = DateTime(date.year, date.month, date.day);
    final daysLeft = expDay.difference(today).inDays;
    final isExpired = daysLeft < 0;
    final isSoon = !isExpired && daysLeft <= 14;

    final Color bg;
    final Color fg;
    if (isExpired) {
      bg = theme.colorScheme.errorContainer;
      fg = theme.colorScheme.onErrorContainer;
    } else if (isSoon) {
      bg = theme.colorScheme.tertiaryContainer;
      fg = theme.colorScheme.onTertiaryContainer;
    } else {
      bg = theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
      fg = theme.colorScheme.onPrimaryContainer;
    }

    final label = isExpired
        ? l10n.expiredLabel
        : l10n.expiresLabel(
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}',
          );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
