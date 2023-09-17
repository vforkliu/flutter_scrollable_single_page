import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'color_screen.dart';
import 'shape_screen.dart';
import 'package:common/model/shape_border_type.dart';

class HomePage extends Page {
  final Function(String) onColorTap;

  HomePage({required this.onColorTap}) : super(key: ValueKey('HomePage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => HomeScreen(onColorTap: onColorTap),
    );
  }
}

class ColorPage extends Page {
  final Function(ShapeBorderType) onShapeTap;
  final String selectedColorCode;

  ColorPage({
    required this.selectedColorCode,
    required this.onShapeTap,
  }) : super(key: ValueKey(selectedColorCode));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => ColorScreen(
        onShapeTap: onShapeTap,
        colorCode: selectedColorCode,
      ),
    );
  }
}

class ShapePage extends Page {
  final String colorCode;
  final ShapeBorderType shapeBorderType;

  ShapePage({
    required this.shapeBorderType,
    required this.colorCode,
  }) : super(key: ValueKey("$colorCode$shapeBorderType"));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => ShapeScreen(
        colorCode: colorCode,
        shapeBorderType: shapeBorderType,
      ),
    );
  }
}

class MyAppRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  MyAppRouterDelegate();

  String? _selectedColorCode;
  String? get selectedColorCode => _selectedColorCode;
  set selectedColorCode(String? value) {
    _selectedColorCode = value;
    notifyListeners();
  }

  ShapeBorderType? _selectedShapeBorderType;
  ShapeBorderType? get selectedShapeBorderType => _selectedShapeBorderType;
  set selectedShapeBorderType(ShapeBorderType? value) {
    _selectedShapeBorderType = value;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final selectedShapeBorderType = this.selectedShapeBorderType;
    final selectedColorCode = this.selectedColorCode;
    return Navigator(
      key: navigatorKey,
      pages: [
        HomePage(
          onColorTap: (String colorCode) {
            this.selectedColorCode = colorCode;
          },
        ),
        if (selectedColorCode != null)
          ColorPage(
            selectedColorCode: selectedColorCode,
            onShapeTap: (ShapeBorderType shape) {
              this.selectedShapeBorderType = shape;
            },
          ),
        if (selectedColorCode != null && selectedShapeBorderType != null)
          ShapePage(
            colorCode: selectedColorCode,
            shapeBorderType: selectedShapeBorderType,
          )
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        if (selectedShapeBorderType == null) this.selectedColorCode = null;
        this.selectedShapeBorderType = null;
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {/* Do Nothing */}
}