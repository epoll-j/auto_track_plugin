import 'dart:collection';

import 'package:flutter/material.dart';

class XPath {
  XPath._(this._targetElement);

  factory XPath.createBy({
    required Element element,
    required Element pageElement,
  }) {
    XPath xpath = XPath._(element);
    xpath._targetElement = element;

    final highLevelSet = _PathConst.highLevelSet;
    LinkedList<_ElementEntry> originalPath = LinkedList();
    originalPath.add(_ElementEntry(element));

    bool lookForTarget = true;
    element.visitAncestorElements((parent) {
      if (parent.widget is GestureDetector) {
        lookForTarget = false;
      }
      if (lookForTarget && highLevelSet.contains(parent.widget.runtimeType)) {
        xpath._targetElement = parent;
      }
      originalPath.add(_ElementEntry(parent));
      if (pageElement == parent) {
        return false;
      }
      return true;
    });

    LinkedList<PathNode> path = xpath._buildFromOriginal(xpath._targetElement, originalPath);
    xpath._shortPath(path);

    if (path.isNotEmpty) {
      path.first.isPage = true;
    }
    for (var node in path) {
      node.computeIndex();
    }
    xpath._path = path;

    return xpath;
  }

  Element _targetElement;
  Element get targetElement => _targetElement;

  LinkedList<PathNode> _path = LinkedList();
  LinkedList<PathNode> get path => _path;

  LinkedList<PathNode> _buildFromOriginal(Element targetElement, LinkedList<_ElementEntry> originalPath) {
    LinkedList<PathNode> path = LinkedList();
    if (originalPath.isEmpty) {
      return path;
    }

    _ElementEntry? entry = originalPath.last;
    while (entry != null) {
      PathNode node = PathNode(entry.element);
      if (!node.ignore) {
        node.formatName();
        path.add(node);
      }
      if (entry.element == targetElement) {
        break;
      }
      entry = entry.previous;
    }
    return path;
  }

  void _shortPath(LinkedList<PathNode> path) {
    if (path.isEmpty) {
      return;
    }

    final shortWidgetMap = _PathConst.shortWidgetMap;
    PathNode? node = path.first;
    while (node != null) {
      if (shortWidgetMap.containsKey(node.name)) {
        _ShortWidgetConfig short = shortWidgetMap[node.name]!;
        node = _removeInternal(path, node, short);
      } else {
        node = node.next;
      }
    }
  }

  PathNode? _removeInternal(LinkedList<PathNode> path, PathNode node, _ShortWidgetConfig short) {
    PathNode? internalNode = node.next;
    Element? indexElement;
    for (String internalWidgetName in short.internalWidgets) {
      if (internalNode == null) {
        return null;
      }

      if (internalNode.name != internalWidgetName) {
        return internalNode;
      }
      if (internalWidgetName == short.indexWidget) {
        indexElement = internalNode.indexElement;
      }
      PathNode tmpNode = internalNode;
      internalNode = internalNode.next;
      path.remove(tmpNode);
    }
    if (indexElement != null) {
      internalNode?.indexElement = indexElement;
    }
    return internalNode;
  }

  @override
  String toString() {
    return path.join('/');
  }
}

final class _ElementEntry extends LinkedListEntry<_ElementEntry> {
  _ElementEntry(this.element);
  final Element element;
}

final class PathNode extends LinkedListEntry<PathNode> {
  PathNode(this.indexElement) {
    _name = indexElement.widget.runtimeType.toString();
    _checkIgnore(indexElement);
  }

  String _name = '';
  String get name => _name;

  int _index = 0;
  int get index => _index;

  bool _ignore = false;
  bool get ignore => _ignore;

  bool isPage = false;
  Element indexElement;

  void formatName() {
    String widgetName = _name;
    int index = widgetName.indexOf('\<');
    if (index > -1) {
      _name = widgetName.substring(0, index);
    }
  }

  void _checkIgnore(Element element) {
    Widget widget = element.widget;
    if (widget is! StatelessWidget && widget is! StatefulWidget) {
      _ignore = true;
      return;
    }

    if (_name[0] == '_') {
      _ignore = true;
      return;
    }
  }

  void computeIndex() {
    Element? parent;
    indexElement.visitAncestorElements((element) {
      parent = element;
      return false;
    });
    if (parent == null) {
      isPage = true;
      return;
    }

    bool found = false;
    _index = 0;
    parent!.visitChildElements((element) {
      if (element == indexElement) {
        found = true;
      }
      if (!found) {
        _index++;
      }
    });
  }

  @override
  String toString() {
    if (isPage) {
      return _name;
    }
    return '$_name[$_index]';
  }
}

class _PathConst {
  static final Set<Type> highLevelSet = {
    InkWell,
    ElevatedButton,
    IconButton,
    TextButton,
    ListTile,
  };
  /// key: Widget Name, value: Widget Name who handle child/children
  static final Map<String, _ShortWidgetConfig> shortWidgetMap = {
    'Scaffold': _ShortWidgetConfig([
      'ScrollNotificationObserver',
      'Material',
      'AnimatedPhysicalModel',
      'AnimatedDefaultTextStyle',
      'AnimatedBuilder',
      'Actions'
    ]),
    'AppBar': _ShortWidgetConfig([
      'Material',
      'AnimatedPhysicalModel',
      'AnimatedDefaultTextStyle',
      'SafeArea',
      'Builder',
      'NavigationToolbar',
    ]),
    'BottomNavigationBar': _ShortWidgetConfig([
      'Material',
      'AnimatedPhysicalModel',
      'AnimatedDefaultTextStyle',
      'Material',
      'AnimatedDefaultTextStyle',
      'Builder',
    ]),
    'ListView': _ShortWidgetConfig([
      'Scrollable',
      'RawGestureDetector',
      'KeyedSubtree',
      'AutomaticKeepAlive',
    ], indexWidget: 'KeyedSubtree'),
    'PageView': _ShortWidgetConfig([
      'Scrollable',
      'RawGestureDetector',
      'SliverFillViewport',
      'KeyedSubtree',
      'AutomaticKeepAlive',
    ], indexWidget: 'KeyedSubtree'),
    'Card': _ShortWidgetConfig([
      'Container',
      'Material',
      'AnimatedDefaultTextStyle',
    ]),
    'IconButton': _ShortWidgetConfig([
      'InkResponse',
      'Actions',
      'Focus',
      'GestureDetector',
      'RawGestureDetector',
    ]),
    'InkResponse': _ShortWidgetConfig([
      'Actions',
      'Focus',
      'GestureDetector',
    ]),
  };
}

class _ShortWidgetConfig {
  _ShortWidgetConfig(this.internalWidgets, { this.indexWidget });
  final List<String> internalWidgets;
  final String? indexWidget;
}
