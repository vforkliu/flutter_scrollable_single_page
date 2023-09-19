import 'package:common/model/shape_border_type.dart';
import 'package:flutter/material.dart';
import 'screens.dart';
import 'package:common/data/auth_repository.dart';
import 'package:common/data/colors_repository.dart';

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

class MyAppRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final AuthRepository authRepository;
  final ColorsRepository colorsRepository;

  bool? _loggedIn;
  bool? get loggedIn => _loggedIn;
  set loggedIn(value) {
    _loggedIn = value;
    notifyListeners();
  }

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

  List<Color>? _colors;
  List<Color>? get colors => _colors;
  set colors(List<Color>? value) {
    _colors = value;
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
  Widget build(BuildContext context) {
    List<Page> stack;
    final loggedIn = this.loggedIn;
    final colors = this.colors;
    if (loggedIn == null || (loggedIn && colors == null)) {
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

  List<Page> get _loggedOutStack => [
    LoginPage(onLogin: () async {
      loggedIn = true;
      colors = await colorsRepository.fetchColors();
    })
  ];

  List<Page> _loggedInStack(List<Color> colors) {
    onLogout() async {
      loggedIn = false;
      _clear();
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
          onShapeTap: (ShapeBorderType shape) {
            this.selectedShapeBorderType = shape;
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

  _clear() {
    selectedColorCode = null;
    selectedShapeBorderType = null;
    colors = null;
  }

  Future<void> setNewRoutePath(configuration) async {/* Do Nothing */}
}