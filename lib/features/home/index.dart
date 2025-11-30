import 'package:flutter/material.dart';
import 'package:win_explorer/features/headerBar/index.dart';
import 'package:win_explorer/features/mainContent/index.dart';
import 'package:win_explorer/features/sidebar/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _sliderWidth = 250;
  double get screenWidth => MediaQuery.sizeOf(context).width;
  double get screenHeight => MediaQuery.sizeOf(context).height;
  bool _isHovering = false;
  bool _isDragging = false;
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
                    Positioned(
                      left: _sliderWidth - 10,
                      width: 20,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          setState(() {
                            _isDragging = true;
                          });
                        },
                        onPanUpdate: (details) {
                          _sliderWidth += details.delta.dx;
                          // 对_sliderWidth进行边界限制
                          _sliderWidth = _sliderWidth.clamp(
                            250.0,
                            screenWidth - 250.0,
                          );
                          setState(() {});
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _isDragging = false;
                            if (!_isHovering) {
                              _currentCursor = SystemMouseCursors.basic;
                            }
                          });
                        },
                        onPanCancel: () {
                          setState(() {
                            _isDragging = false;
                            if (!_isHovering) {
                              _currentCursor = SystemMouseCursors.basic;
                            }
                          });
                        },
                        child: MouseRegion(
                          onEnter: (event) {
                            setState(() {
                              _isHovering = true;
                              _currentCursor = SystemMouseCursors.resizeColumn;
                            });
                          },
                          onExit: (event) {
                            setState(() {
                              _isHovering = false;
                              if (!_isDragging) {
                                _currentCursor = SystemMouseCursors.basic;
                              }
                            });
                          },
                          child: Container(
                            // 可选：根据悬停状态改变颜色，提供更明显的反馈
                            color: (_isHovering || _isDragging)
                                ? Color.fromRGBO(255, 0, 0, 0.8) // 悬停或拖拽时更醒目的颜色
                                : Color.fromRGBO(0, 0, 255, 0.5),
                          ),
                        ),
                      ),
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
