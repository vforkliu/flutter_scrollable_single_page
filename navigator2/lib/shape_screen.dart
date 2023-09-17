import 'package:common/extensions/color_extensions.dart';
import 'package:common/model/shape_border_type.dart';
import 'package:common/widgets/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:common/widgets/app_bar_back_button.dart';
import 'package:common/widgets/shaped_button.dart';

class ShapeScreen extends StatelessWidget {
  final String colorCode;
  final ShapeBorderType shapeBorderType;

  Color get color => colorCode.hexToColor();

  const ShapeScreen({
    Key? key,
    required this.colorCode,
    required this.shapeBorderType,
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
          backgroundColor: color,
        ),
        body: Center(
          child: ShapedButton(
            color: color,
            shapeBorderType: shapeBorderType,
          ),
        ));
  }
}