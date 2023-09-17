import 'dart:math';

import 'package:common/extensions/color_extensions.dart';
import 'package:common/model/shape_border_type.dart';
import 'package:flutter/material.dart';
import 'shape_border_listview.dart';
import 'package:common/entity/color_code.dart';

class ColorSections extends StatefulWidget {
  final List<MaterialColor> colors;
  final ValueNotifier<ShapeBorderType?> shapeBorderTypeNotifier;
  final ValueNotifier<ColorCode?> colorCodeNotifier;

  ColorSections({
    Key? key,
    required this.colors,
    required this.shapeBorderTypeNotifier,
    required this.colorCodeNotifier,
  }) : super(key: key) {
    print("reconstructing HomeScreen");
  }

  @override
  State<ColorSections> createState() => _ColorSectionsState();
}

class _ColorSectionsState extends State<ColorSections> {
  final double _minItemHeight = 700;

  ScrollController _scrollController = ScrollController();

  double _calculateItemHeight({required double availableHeight}) {
    return max(availableHeight, _minItemHeight);
  }

  // Find the index of the color code from the colors list
  int get _colorCodeIndex {
    int index = widget.colors.indexWhere((element) {
      final hexColorCode = widget.colorCodeNotifier.value?.hexColorCode;
      return element.toHex() == hexColorCode;
    });
    return index > -1 ? index : 0;
  }

  @override
  void initState() {
    super.initState();
    widget.colorCodeNotifier.addListener(() {
      final fromScroll =
          widget.colorCodeNotifier.value?.source == ColorCodeSelectionSource.fromScroll;
      if (_scrollController.hasClients && !fromScroll) {
        // 事件源不是用户通过鼠标等导致的页面滚动，而是通过菜单，才开始滚动
        _scrollToSection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      /// 每个item的高度，而不是child的高度?
      builder: (BuildContext context, BoxConstraints constraints) {
        final itemHeight = _calculateItemHeight(availableHeight: constraints.maxHeight);
        _scrollController = ScrollController(initialScrollOffset: itemHeight * _colorCodeIndex);
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            /// 区分是否是用户滚动
            if (notification is UserScrollNotification) {
              _onUserScroll(notification.metrics.pixels);
            }
            return true;
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.colors.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              final color = widget.colors[index];
              return Container(
                height: itemHeight,
                color: color.shade100,
                child: _section(color, context),
              );
            },
          ),
        );
      },
    );
  }

  void _onUserScroll(double offset) {
    final itemHeight =
    _calculateItemHeight(availableHeight: _scrollController.position.viewportDimension);
    final trailingIndex = (offset / itemHeight).floor();
    final hexColorCode = widget.colors[trailingIndex].toHex();
    widget.colorCodeNotifier.value = ColorCode(
      hexColorCode: hexColorCode,
      source: ColorCodeSelectionSource.fromScroll,
    );
  }

  Widget _section(MaterialColor color, BuildContext context) {
    return ShapeBorderListView(
      sectionColor: color,
      shapeBorderTypeNotifier: widget.shapeBorderTypeNotifier,
      colorCodeNotifier: widget.colorCodeNotifier,
    );
  }

  void _scrollToSection() {
    // 一般情况下，在widget没有渲染完成前，应该无法知道尺寸，如果需要提前知道，可使用LayoutBuilder
    final itemHeight = _calculateItemHeight(availableHeight: context.size!.height);
    final offset = _colorCodeIndex * itemHeight;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300), // 动画时长
      curve: Curves.easeInOut,// 动画曲线
    );
  }
}
