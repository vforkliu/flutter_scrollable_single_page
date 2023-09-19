import 'package:common/extensions/color_extensions.dart';
import 'package:common/model/shape_border_type.dart';
import 'package:common/widgets/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'fab_logout.dart';
import 'package:common/widgets/app_bar_back_button.dart';
import 'package:common/viewmodels/auth_view_model.dart';
import 'package:common/widgets/in_progress_message.dart';
import 'package:common/widgets/shape_border_gridview.dart';
import 'package:common/widgets/color_gridview.dart';
import 'package:provider/provider.dart';
import 'package:common/widgets/shaped_button.dart';

class ColorScreen extends StatelessWidget {
  final String colorCode;
  final Function(ShapeBorderType) onShapeTap;
  final VoidCallback onLogout;

  Color get color => colorCode.hexToColor();

  const ColorScreen({
    Key? key,
    required this.colorCode,
    required this.onShapeTap,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: LogoutFab(onLogout: onLogout, color: color),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: AppBarText(appBarColor: color, text: '#$colorCode'),
      backgroundColor: color,
      leading: AppBarBackButton(color: color),
      //brightness: ThemeData.estimateBrightnessForColor(color),
    );
  }

  Widget _body(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    return authViewModel.logingOut
        ? const InProgressMessage(progressName: "Logout", screenName: "ColorScreen")
        : ShapeBorderGridView(
      color: color,
      onShapeTap: onShapeTap,
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Function(String) onColorTap;
  final VoidCallback onLogout;

  const HomeScreen({
    Key? key,
    required this.onColorTap,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: _colorList(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: LogoutFab(onLogout: onLogout),
    );
  }

  Widget _colorList(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    return authViewModel.logingOut
        ? const InProgressMessage(progressName: "Logout", screenName: "HomeScreen")
        : ColorGrid(
      colors: Colors.primaries.reversed.toList(),
      onColorTap: onColorTap,
    );
  }
}

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;

  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Center(
        child: authViewModel.logingIn
            ? const InProgressMessage(progressName: "Login", screenName: "LoginScreen")
            : ElevatedButton(
          onPressed: () async {
            final result = await authViewModel.login();
            if (result == true) onLogin();
          },
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Log in'),
          ),
        ),
      ),
    );
  }
}

class ShapeScreen extends StatelessWidget {
  final String colorCode;
  final ShapeBorderType shapeBorderType;
  final VoidCallback onLogout;

  Color get color => colorCode.hexToColor();

  const ShapeScreen({
    Key? key,
    required this.colorCode,
    required this.shapeBorderType,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarText(
          appBarColor: color,
          text: '${shapeBorderType.stringRepresentation().toUpperCase()} #$colorCode ',
        ),
        backgroundColor: colorCode.hexToColor(),
        leading: AppBarBackButton(color: color),
      ),
      body: _body(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: LogoutFab(onLogout: onLogout, color: color),
    );
  }

  Widget _body(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    return authViewModel.logingOut
        ? const InProgressMessage(progressName: "Logout", screenName: "ShapeScreen")
        : Center(
      child: ShapedButton(
        shapeBorderType: shapeBorderType,
        color: color,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final String process;

  const SplashScreen({Key? key, required this.process}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
            'Splash !!!!!\n\n$process',
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          )),
    );
  }
}

