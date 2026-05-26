import 'package:flutter/material.dart';

/// Global keys for tutorial spotlight targets, shared across screens.
class TutorialTargetRegistry {
  TutorialTargetRegistry._();

  static final Map<String, GlobalKey> _keys = {};

  static GlobalKey keyFor(String id) {
    return _keys.putIfAbsent(id, () => GlobalKey(debugLabel: 'tutorial_$id'));
  }

  static Rect? globalRect(String id) {
    final context = _keys[id]?.currentContext;
    if (context == null) return null;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  static List<Rect> globalRects(Iterable<String> ids) {
    return ids.map(globalRect).whereType<Rect>().toList();
  }
}
