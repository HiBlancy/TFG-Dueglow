import 'package:flutter/material.dart';
import '../tutorial/tutorial_target_registry.dart';

/// Wraps a widget so the tutorial overlay can spotlight it by [id].
class TutorialTarget extends StatelessWidget {
  final String id;
  final Widget child;

  const TutorialTarget({
    super.key,
    required this.id,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: TutorialTargetRegistry.keyFor(id),
      child: child,
    );
  }
}
