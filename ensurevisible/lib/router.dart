import 'package:common/model/shape_border_type.dart';
import 'package:common/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:common/entity/color_code.dart';
import 'package:common/widgets/shape_dialog.dart';
import 'package:common/widgets/unknown_screen.dart';
import 'home_screen.dart';

class SinglePageAppConfiguration {
  final String? colorCode;
  final ShapeBorderType? shapeBorderType;
  final bool unknown;

  SinglePageAppConfiguration.home({this.colorCode})
      : unknown = false,
        shapeBorderType = null;

  SinglePageAppConfiguration.shapeBorder(this.colorCode, ShapeBorderType? shape)
      : unknown = false,
        shapeBorderType = shape;

  SinglePageAppConfiguration.unknown()
      : unknown = true,
        shapeBorderType = null,
        colorCode = null;

  bool get isUnknown => unknown == true;

  bool get isHomePage => unknown == false && shapeBorderType == null;

  bool get isShapePage => unknown == false && colorCode != null && shapeBorderType != null;
}

class SinglePageAppRouteInformationParser
    extends RouteInformationParser<SinglePageAppConfiguration> {
  final List<MaterialColor> colors;

  SinglePageAppRouteInformationParser({required this.colors});

  @override
  Future<SinglePageAppConfiguration> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.isEmpty) {
      return SinglePageAppConfiguration.home();
    } else if (uri.pathSegments.length == 2) {
      final first = uri.pathSegments[0].toLowerCase();
      final second = uri.pathSegments[1].toLowerCase();
      if (first == 'colors' && _isValidColor(second)) {
        return SinglePageAppConfiguration.home(colorCode: second);
      } else {
        return SinglePageAppConfiguration.unknown();
      }
    } else if (uri.pathSegments.length == 3) {
      final first = uri.pathSegments[0].toLowerCase();
      final second = uri.pathSegments[1].toLowerCase();
      final third = uri.pathSegments[2].toLowerCase();
      final shapeBorderType = extractShapeBorderType(third);
      if (first == 'colors' && shapeBorderType != null) {
        return SinglePageAppConfiguration.shapeBorder(
          second,
          shapeBorderType,
        );
      } else {
        return SinglePageAppConfiguration.unknown();
      }
    } else {
      return SinglePageAppConfiguration.unknown();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(SinglePageAppConfiguration configuration) {
    if (configuration.isUnknown) {
      return RouteInformation(location: '/unknown');
    } else if (configuration.isHomePage) {
      return RouteInformation(
        location: configuration.colorCode == null ? '/' : '/colors/${configuration.colorCode}',
      );
    } else if (configuration.isShapePage) {
      final borderType = configuration.shapeBorderType?.stringRepresentation();
      final location = '/colors/${configuration.colorCode}/$borderType';
      return RouteInformation(location: location);
    } else {
      return null;
    }
  }

  bool _isValidColor(String colorCode) {
    final List<String> colorCodes = colors.map((e) {
      return e.toHex();
    }).toList();
    return colorCodes.contains("$colorCode");
  }

  ShapeBorderType? extractShapeBorderType(String shapeBorderTypeValue) {
    final value = shapeBorderTypeValue.toLowerCase();
    switch (value) {
      case CONTINUOUS_SHAPE:
        return ShapeBorderType.CONTINUOUS;
      case BEVELED_SHAPE:
        return ShapeBorderType.BEVELED;
      case ROUNDED_SHAPE:
        return ShapeBorderType.ROUNDED;
      case STADIUM_SHAPE:
        return ShapeBorderType.STADIUM;
      case CIRCLE_SHAPE:
        return ShapeBorderType.CIRCLE;
      default:
        return null;
    }
  }
}

class ShapePage extends Page {
  final String colorCode;
  final ShapeBorderType shapeBorderType;

  static const String routeName = "ShapePage";

  @override
  String get name => routeName;

  ShapePage({
    required this.shapeBorderType,
    required this.colorCode,
  }) : super(key: ValueKey("$colorCode$shapeBorderType"));

  @override
  Route createRoute(BuildContext context) {
    return CupertinoDialogRoute(
      settings: this,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (BuildContext context) => ShapeDialog(
        colorCode: colorCode,
        shapeBorderType: shapeBorderType,
      ),
      context: context,
    );
  }
}

class SinglePageAppRouterDelegate extends RouterDelegate<SinglePageAppConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<SinglePageAppConfiguration> {
  final List<MaterialColor> colors;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  late Page _homePage;

  // App state fields
  final ValueNotifier<ColorCode?> _colorCodeNotifier = ValueNotifier(null);
  final ValueNotifier<ShapeBorderType?> _shapeBorderTypeNotifier = ValueNotifier(null);
  final ValueNotifier<bool?> _unknownStateNotifier = ValueNotifier(null);

  String get defaultColorCode => colors.first.toHex();

  SinglePageAppRouterDelegate({required this.colors}) {
    _homePage = MaterialPage(
      key: ValueKey<String>("HomePage"),
      child: HomeScreen(
        colors: colors,
        colorCodeNotifier: _colorCodeNotifier,
        shapeBorderTypeNotifier: _shapeBorderTypeNotifier,
      ),
    );
    Listenable.merge([
      _shapeBorderTypeNotifier,
      _unknownStateNotifier,
      _colorCodeNotifier,
    ])
      .addListener(() {
        print("notifying the router widget");
        notifyListeners();
      });
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  SinglePageAppConfiguration get currentConfiguration {
    if (_unknownStateNotifier.value == true) {
      return SinglePageAppConfiguration.unknown();
    } else if (_shapeBorderTypeNotifier.value != null) {
      return SinglePageAppConfiguration.shapeBorder(
        _colorCodeNotifier.value!.hexColorCode,
        _shapeBorderTypeNotifier.value,
      );
    } else {
      return SinglePageAppConfiguration.home(
        colorCode: _colorCodeNotifier.value?.hexColorCode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorCode = _colorCodeNotifier.value;
    final shapeBorderType = _shapeBorderTypeNotifier.value;
    return Navigator(
      key: navigatorKey,
      pages: _unknownStateNotifier.value == true
          ? [
        const MaterialPage(
          key: ValueKey<String>("Unknown"),
          child: UnknownScreen(),
        )
      ]
          : [
        _homePage,
        if (colorCode != null && shapeBorderType != null)
          ShapePage(
            colorCode: colorCode.hexColorCode,
            shapeBorderType: shapeBorderType,
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        if (route.settings.name == ShapePage.routeName) {
          _shapeBorderTypeNotifier.value = null;
        }
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(SinglePageAppConfiguration configuration) async {
    if (configuration.unknown) {
      _unknownStateNotifier.value = true;
      _colorCodeNotifier.value = null;
      _shapeBorderTypeNotifier.value = null;
    } else if (configuration.isHomePage) {
      _unknownStateNotifier.value = false;
      _colorCodeNotifier.value = ColorCode(
        hexColorCode: configuration.colorCode ?? defaultColorCode,
        source: ColorCodeSelectionSource.fromBrowserAddressBar,
      );
      _shapeBorderTypeNotifier.value = null;
    } else if (configuration.isShapePage) {
      _unknownStateNotifier.value = false;
      _colorCodeNotifier.value = ColorCode(
        hexColorCode: configuration.colorCode!,
        source: ColorCodeSelectionSource.fromBrowserAddressBar,
      );
      _shapeBorderTypeNotifier.value = configuration.shapeBorderType;
    }
  }
}