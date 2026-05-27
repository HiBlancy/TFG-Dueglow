import 'package:flutter/material.dart';

/// Bottom navigation with per-tab [GlobalKey]s for tutorial spotlights.
class TutorialBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final List<GlobalKey> tabKeys;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;
  final bool showLabels;

  const TutorialBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.tabKeys,
    required this.selectedColor,
    required this.unselectedColor,
    required this.backgroundColor,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    assert(items.length == tabKeys.length);

    return Material(
      color: backgroundColor,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;
              final color = selected ? selectedColor : unselectedColor;

              return Expanded(
                child: KeyedSubtree(
                  key: tabKeys[index],
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconTheme(
                          data: IconThemeData(color: color, size: 24),
                          child: selected
                              ? item.activeIcon
                              : item.icon,
                        ),
                        if (showLabels && item.label != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.label!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
