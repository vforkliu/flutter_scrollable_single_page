import 'package:flutter/material.dart';
import 'package:common/widgets/color_gridview.dart';

class HomeScreen extends StatelessWidget {
  final Function(String) onColorTap;
  final List<Color> colors = Colors.primaries.reversed.toList();

  HomeScreen({Key? key, required this.onColorTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: ColorGrid(
        colors: Colors.primaries.reversed.toList(),
        onColorTap: onColorTap,
      ),
    );
  }
}