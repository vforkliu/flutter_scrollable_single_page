import 'package:common/extensions/color_extensions.dart';
import 'package:common/model/shape_border_type.dart';
import 'package:common/widgets/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:common/widgets/app_bar_back_button.dart';
import 'package:common/widgets/shape_border_gridview.dart';

class ColorScreen extends StatelessWidget {
  final String colorCode;
  final Function(ShapeBorderType) onShapeTap;

  Color get color => colorCode.hexToColor();

  const ColorScreen({
    Key? key,
    required this.colorCode,
    required this.onShapeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarText(appBarColor: color, text: '#$colorCode'),
        backgroundColor: colorCode.hexToColor(),
        leading: AppBarBackButton(color: color),
      ),
      body: ShapeBorderGridView(
        color: color,
        onShapeTap: onShapeTap,
      ),
    );
  }
}