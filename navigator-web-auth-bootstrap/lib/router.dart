import 'package:common/extensions/color_extensions.dart';
import 'package:common/model/shape_border_type.dart';
import 'package:flutter/material.dart';
import 'screens.dart';
import 'package:common/data/auth_repository.dart';
import 'package:common/data/colors_repository.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class ColorPage extends Page {
  final Function(ShapeBorderType) onShapeTap;
  final String selectedColorCode;
  final VoidCallback onLogout;

  ColorPage({
    required this.onLogout,
    required this.selectedColorCode,
    required this.onShapeTap,
  }) : super(key: ValueKey(selectedColorCode));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return ColorScreen(
          onShapeTap: onShapeTap,
          colorCode: selectedColorCode,
          onLogout: onLogout,
        );
      },
    );
  }
}

class HomePage extends Page {
  final Function(String) onColorTap;
  final VoidCallback onLogout;
  final List<Color> colors;

  const HomePage({
    required this.onColorTap,
    required this.onLogout,
    required this.colors,
  }) : super(key: const ValueKey('HomePage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return HomeScreen(
          onColorTap: onColorTap,
          onLogout: onLogout,
          colors: colors,
        );
      },
    );
  }
}

class LoginPage extends Page {
  final VoidCallback onLogin;

  LoginPage({required this.onLogin}) : super(key: ValueKey('LoginPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return LoginScreen(onLogin: onLogin);
      },
    );
  }
}

class ShapePage extends Page {
  final String colorCode;
  final ShapeBorderType shapeBorderType;
  final VoidCallback onLogout;

  ShapePage({
    required this.shapeBorderType,
    required this.colorCode,
    required this.onLogout,
  }) : super(key: ValueKey("$colorCode$shapeBorderType"));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return ShapeScreen(
          colorCode: colorCode,
          shapeBorderType: shapeBorderType,
          onLogout: onLogout,
        );
      },
    );
  }
}

class SplashPage extends Page {
  final String process;

  SplashPage({required this.process}) : super(key: ValueKey('SplashPage$process'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return SplashScreen(process: process);
      },
    );
  }
}

class UnknownPage extends Page {

  const UnknownPage() : super(key: const ValueKey('UnknownPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return const UnknownScreen();
        });
  }
}


class MyAppConfiguration {
  final String? colorCode;
  final ShapeBorderType? shapeBorderType;
  final bool unknown;
  final bool? loggedIn;

  MyAppConfiguration.splash()
      : unknown = false,
        loggedIn = null,
        shapeBorderType = null,
        colorCode = null;

  MyAppConfiguration.login()
      : unknown = false,
        loggedIn = false,
        shapeBorderType = null,
        colorCode = null;

  MyAppConfiguration.shapeBorder(this.colorCode, ShapeBorderType? shape)
      : unknown = false,
        shapeBorderType = shape,
        loggedIn = true;

  MyAppConfiguration.color(this.colorCode)
      : unknown = false,
        shapeBorderType = null,
        loggedIn = true;

  MyAppConfiguration.home()
      : unknown = false,
        shapeBorderType = null,
        loggedIn = true,
        colorCode = null;

  MyAppConfiguration.unknown()
      : unknown = true,
        shapeBorderType = null,
        loggedIn = null,
        colorCode = null;

  bool get isUnknown => unknown == true;
  bool get isHomePage =>
      unknown == false && loggedIn == true && colorCode == null && shapeBorderType == null;
  bool get isColorPage =>
      unknown == false && loggedIn == true && colorCode != null && shapeBorderType == null;
  bool get isShapePage =>
      unknown == false && loggedIn == true && colorCode != null && shapeBorderType != null;
  bool get isLoginPage => unknown == false && loggedIn == false;
  bool get isSplashPage => unknown == false && loggedIn == null;
}

class MyAppRouteInformationParser extends RouteInformationParser<MyAppConfiguration> {
  @override
  Future<MyAppConfiguration> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.length == 0) {
      return MyAppConfiguration.home();
    } else if (uri.pathSegments.length == 1) {
      final first = uri.pathSegments[0].toLowerCase();
      if (first == 'home') {
        return MyAppConfiguration.home();
      } else if (first == 'login') {
        return MyAppConfiguration.login();
      } else {
        return MyAppConfiguration.unknown();
      }
    } else if (uri.pathSegments.length == 2) {
      final first = uri.pathSegments[0].toLowerCase();
      final second = uri.pathSegments[1].toLowerCase();
      if (first == 'colors' && second.length == 6 && second.isHexColor()) {
        return MyAppConfiguration.color(second);
      } else {
        return MyAppConfiguration.unknown();
      }
    } else if (uri.pathSegments.length == 3) {
      final first = uri.pathSegments[0].toLowerCase();
      final second = uri.pathSegments[1].toLowerCase();
      final third = uri.pathSegments[2].toLowerCase();
      final shapeBorderType = extractShapeBorderType(third);
      if (first == 'colors' &&
          second.length == 6 &&
          second.isHexColor() &&
          shapeBorderType != null) {
        return MyAppConfiguration.shapeBorder(second, shapeBorderType);
      } else {
        return MyAppConfiguration.unknown();
      }
    } else {
      return MyAppConfiguration.unknown();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(MyAppConfiguration configuration) {
    if (configuration.isUnknown) {
      return RouteInformation(location: '/unknown');
    } else if (configuration.isSplashPage) {
      return null;
    } else if (configuration.isLoginPage) {
      return RouteInformation(location: '/login');
    } else if (configuration.isHomePage) {
      return RouteInformation(location: '/');
    } else if (configuration.isColorPage) {
      return RouteInformation(location: '/colors/${configuration.colorCode}');
    } else if (configuration.isShapePage) {
      return RouteInformation(
          location:
          '/colors/${configuration.colorCode}/${configuration.shapeBorderType?.stringRepresentation()}');
    } else {
      return null;
    }
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



class MyAppRouterDelegate extends RouterDelegate<MyAppConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<MyAppConfiguration> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final AuthRepository authRepository;
  final ColorsRepository colorsRepository;

  bool? _show404;
  bool? get show404 => _show404;
  set show404(bool? value) {
    _show404 = value;
    if (value == true) {
      selectedColorCode = null;
      selectedShapeBorderType = null;
    }
    notifyListeners();
  }

  bool? _loggedIn;
  bool? get loggedIn => _loggedIn;
  set loggedIn(value) {
    if (_loggedIn == true && value == false) {
      // It is a logout!
      _clear();
    }
    _loggedIn = value;
    notifyListeners();
  }

  List<Color>? _colors;
  List<Color>? get colors => _colors;
  set colors(List<Color>? value) {
    _colors = value;
    final selectedColorCode = this.selectedColorCode;
    if (value != null && selectedColorCode != null) {
      show404 = !_isValidColor(value, selectedColorCode);
    }
    notifyListeners();
  }

  String? _selectedColorCode;
  String? get selectedColorCode => _selectedColorCode;
  set selectedColorCode(String? value) {
    final colors = this.colors;
    if (colors != null && value != null) {
      show404 = !_isValidColor(colors, value);
    }
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
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  MyAppRouterDelegate(this.authRepository, this.colorsRepository) {
    _init();
  }

  _init() async {
    loggedIn = await authRepository.isUserLoggedIn();
    if (loggedIn == true) {
      colors = await colorsRepository.fetchColors();
    }
  }

  @override
  MyAppConfiguration? get currentConfiguration {
    if (loggedIn == false) {
      return MyAppConfiguration.login();
    } else if (loggedIn == null) {
      return MyAppConfiguration.splash();
    } else if (show404 == true) {
      return MyAppConfiguration.unknown();
    } else if (selectedColorCode == null) {
      return MyAppConfiguration.home();
    } else if (selectedShapeBorderType == null) {
      return MyAppConfiguration.color(selectedColorCode);
    } else if (selectedShapeBorderType != null) {
      return MyAppConfiguration.shapeBorder(selectedColorCode, selectedShapeBorderType);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Page> stack;
    final loggedIn = this.loggedIn;
    final colors = this.colors;
    if (show404 == true) {
      stack = _unknownStack;
    } else if (loggedIn == null || (loggedIn && colors == null)) {
      stack = _splashStack;
    } else if (loggedIn && colors != null) {
      stack = _loggedInStack(colors);
    } else {
      stack = _loggedOutStack;
    }
    return Navigator(
      key: navigatorKey,
      pages: stack,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        if (selectedShapeBorderType == null) selectedColorCode = null;
        selectedShapeBorderType = null;
        return true;
      },
    );
  }

  List<Page> get _splashStack {
    String? process;
    if (loggedIn == null) {
      process = 'Checking login state...';
    } else if (colors == null) {
      process = 'Fetching colors...';
    } else {
      process = "Unidentified process";
    }
    return [
      SplashPage(process: process),
    ];
  }

  List<Page> get _unknownStack => [UnknownPage()];

  List<Page> get _loggedOutStack => [
    LoginPage(onLogin: () async {
      loggedIn = true;
      colors = await colorsRepository.fetchColors();
    })
  ];

  List<Page> _loggedInStack(List<Color> colors) {
    onLogout() async {
      loggedIn = false;
    }
    final selectedShapeBorderType = this.selectedShapeBorderType;
    final selectedColorCode = this.selectedColorCode;
    return [
      HomePage(
        onColorTap: (String colorCode) {
          this.selectedColorCode = colorCode;
        },
        colors: colors,
        onLogout: onLogout,
      ),
      if (selectedColorCode != null)
        ColorPage(
          selectedColorCode: selectedColorCode,
          onShapeTap: (ShapeBorderType shapeBorderType) {
            this.selectedShapeBorderType = shapeBorderType;
          },
          onLogout: onLogout,
        ),
      if (selectedColorCode != null && selectedShapeBorderType != null)
        ShapePage(
          colorCode: selectedColorCode,
          shapeBorderType: selectedShapeBorderType,
          onLogout: onLogout,
        )
    ];
  }

  @override
  Future<void> setNewRoutePath(MyAppConfiguration configuration) async {
    if (configuration.unknown) {
      show404 = true;
    } else if (configuration.isHomePage ||
        configuration.isLoginPage ||
        configuration.isSplashPage) {
      show404 = false;
      selectedColorCode = null;
      selectedShapeBorderType = null;
    } else if (configuration.isColorPage) {
      show404 = false;
      selectedColorCode = configuration.colorCode;
      selectedShapeBorderType = null;
    } else if (configuration.isShapePage) {
      show404 = false;
      selectedColorCode = configuration.colorCode;
      selectedShapeBorderType = configuration.shapeBorderType;
    } else {
      print(' Could not set new route');
    }
  }

  _clear() {
    selectedColorCode = null;
    selectedShapeBorderType = null;
    colors = null;
    show404 = null;
  }

  bool _isValidColor(List<Color> colors, String colorCode) {
    final List<String> colorCodes = colors.map((e) {
      return e.toHex();
    }).toList();
    return colorCodes.contains("$colorCode");
  }
}