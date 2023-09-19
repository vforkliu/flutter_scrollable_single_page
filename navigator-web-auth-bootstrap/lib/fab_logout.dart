import 'package:common/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:common/viewmodels/auth_view_model.dart';
import 'package:common/viewmodels/colors_view_model.dart';
import 'package:provider/provider.dart';

class LogoutFab extends StatelessWidget {
  final VoidCallback onLogout;
  final Color? color;

  const LogoutFab({Key? key, required this.onLogout, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final colorsViewModel = context.watch<ColorsViewModel>();
    return authViewModel.logingOut || colorsViewModel.clearingColors
        ? _inProgressFab()
        : _extendedFab(authViewModel, colorsViewModel);
  }

  FloatingActionButton _inProgressFab() {
    final color = this.color;
    return FloatingActionButton(
        onPressed: null,
        foregroundColor: color == null ? Colors.white : color.onTextColor(),
        backgroundColor: color,
        child: const CircularProgressIndicator(backgroundColor: Colors.white));
  }

  FloatingActionButton _extendedFab(
      AuthViewModel authViewModel,
      ColorsViewModel colorsViewModel,
      ) {
    final color = this.color;
    return FloatingActionButton.extended(
      icon: const Icon(Icons.exit_to_app),
      onPressed: () async {
        await authViewModel.logout();
        await colorsViewModel.clearColors();
        onLogout();
      },
      foregroundColor: color == null ? Colors.white : color.onTextColor(),
      backgroundColor: color,
      label: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Logout'),
      ),
    );
  }
}