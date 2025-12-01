import 'package:flutter/material.dart';
import 'package:win_explorer/core/constants/global_constants.dart';
import 'package:win_explorer/shared/widgets/resize_divider.dart';
import 'package:win_explorer/features/headerBar/index.dart';
import 'package:win_explorer/features/mainContent/index.dart';
import 'package:win_explorer/features/sidebar/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _sliderWidth = GlobalConstants.sliderMinWidth;
  double get screenWidth => MediaQuery.sizeOf(context).width;
  double get screenHeight => MediaQuery.sizeOf(context).height;
  MouseCursor _currentCursor = SystemMouseCursors.basic;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MouseRegion(
          cursor: _currentCursor,
          child: Flex(
            direction: Axis.vertical,
            children: [
              HeaderBar(),
              Expanded(
                child: Stack(
                  children: [
                    Sidebar(
                      left: 0,
                      right: screenWidth - _sliderWidth,
                      top: 0,
                      bottom: 0,
                    ),
                    MainContent(
                      left: _sliderWidth,
                      right: 0,
                      top: 0,
                      bottom: 0,
                    ),
                    ResizeDivider(
                      left: _sliderWidth,
                      onDrag: (dx) {
                        setState(() {
                          _sliderWidth += dx;
                          _sliderWidth = _sliderWidth.clamp(
                            250.0,
                            screenWidth - 250.0,
                          );
                        });
                      },
                      onCursorChange: (cursor) {
                        setState(() {
                          _currentCursor = cursor;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
