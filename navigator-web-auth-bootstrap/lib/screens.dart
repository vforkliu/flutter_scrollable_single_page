import 'package:common/extensions/color_extensions.dart';
import 'package:common/model/shape_border_type.dart';
import 'package:common/widgets/app_bar_text.dart';
import 'package:common/widgets/app_bar_back_button.dart';
import 'package:common/viewmodels/auth_view_model.dart';
import 'package:common/viewmodels/colors_view_model.dart';
import 'package:common/widgets/in_progress_message.dart';
import 'package:common/widgets/shape_border_gridview.dart';
import 'package:common/widgets/color_gridview.dart';
import 'package:provider/provider.dart';
import 'package:common/dimens/app_dimens.dart';
import 'package:common/widgets/shaped_button.dart';
import 'package:flutter/material.dart';
import 'fab_logout.dart';

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
      appBar: AppBar(
        title: AppBarText(appBarColor: color, text: '#$colorCode'),
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
    final colorsViewModel = context.watch<ColorsViewModel>();
    bool inProgress;
    String? progressName;
    if (authViewModel.logingOut) {
      inProgress = true;
      progressName = "Logout";
    } else if (colorsViewModel.clearingColors) {
      inProgress = true;
      progressName = "Clearing colors";
    } else {
      inProgress = false;
      progressName = null;
    }
    return inProgress && progressName != null
        ? InProgressMessage(progressName: progressName, screenName: "ColorScreen")
        : ShapeBorderGridView(
      color: color,
      onShapeTap: onShapeTap,
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Function(String) onColorTap;
  final List<Color> colors;
  final VoidCallback onLogout;

  const HomeScreen({
    Key? key,
    required this.onColorTap,
    required this.onLogout,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: _body(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: LogoutFab(onLogout: onLogout),
    );
  }

  Widget _body(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final colorsViewModel = context.watch<ColorsViewModel>();
    bool inProgress;
    String? progressName;
    if (authViewModel.logingOut) {
      inProgress = true;
      progressName = "Logout";
    } else if (colorsViewModel.clearingColors) {
      inProgress = true;
      progressName = "Clearing colors";
    } else {
      inProgress = false;
      progressName = null;
    }
    return inProgress && progressName != null
        ? InProgressMessage(progressName: progressName, screenName: "HomeScreen")
        : ColorGrid(colors: colors, onColorTap: onColorTap);
  }
}

class LoginScreen extends StatelessWidget {
  final VoidCallback? onLogin;

  const LoginScreen({Key? key, this.onLogin}) : super(key: key);

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
            final authViewModel = context.read<AuthViewModel>();
            final result = await authViewModel.login();
            if (result == true) {
              onLogin!();
            } else {
              authViewModel.logingIn = false;
            }
          },
          child: const Padding(
            padding: EdgeInsets.all(AppDimens.SIZE_SPACING_MEDIUM),
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
        leading: AppBarBackButton(color: color),
        backgroundColor: colorCode.hexToColor(),
      ),
      body: _body(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: LogoutFab(onLogout: onLogout, color: color),
    );
  }

  Widget _body(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final colorsViewModel = context.watch<ColorsViewModel>();
    bool inProgress;
    String? progressName;
    if (authViewModel.logingOut) {
      inProgress = true;
      progressName = "Logout";
    } else if (colorsViewModel.clearingColors) {
      inProgress = true;
      progressName = "Clearing colors";
    } else {
      inProgress = false;
      progressName = null;
    }
    return inProgress && progressName != null
        ? InProgressMessage(progressName: progressName, screenName: "ShapeScreen")
        : Center(
      child: ShapedButton(
        color: color,
        shapeBorderType: shapeBorderType,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final String? process;

  const SplashScreen({Key? key, this.process}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
            'Splash !!!!!\n\n$process',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          )),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  const UnknownScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ERROR!')),
      body: _colorList(context),
    );
  }

  Widget _colorList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'ERROR: 404\n\n\nPAGE NOT FOUND!',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
