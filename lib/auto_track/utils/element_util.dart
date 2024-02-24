import 'package:flutter/material.dart';

typedef ElementWalker = bool Function(Element child, Element? parent);

class ElementUtil {
  static void walk(BuildContext? context, ElementWalker walker) {
    if (context == null) {
      return;
    }
    context.visitChildElements((element) {
      if (walker(element, null)) {
        walkElement(element, walker);
      }
    });
  }

  static void walkElement(Element element, ElementWalker walker) {
    element.visitChildren((child) {
      if (walker(child, element)) {
        walkElement(child, walker);
      }
    });
  }

  static List<String> findTexts(Element element) {
    List<String> list = [];
    walkElement(element, ((child, _) {
      if (child.widget is Text) {
        String? text = (child.widget as Text).data;
        if (text != null) {
          list.add(text);
        }
        return false;
      }
      return true;
    }));
    return list;
  }

  static Element? findAncestorElementOfWidgetType<T extends Widget>(Element? element) {
    if (element == null) {
      return null;
    }

    Element? target;
    element.visitAncestorElements((parent) {
      if (parent.widget is T) {
        target = parent;
        return false;
      }
      return true;
    });
    return target;
  }
}
