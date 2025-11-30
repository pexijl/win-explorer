import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              height: 120,
              color: Colors.blue,
              child: Center(
                child: Text(
                  'Win Explorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Sidebar(
                    left: 0,
                    right: screenWidth - _sliderWidth,
                    top: 0,
                    bottom: 0,
                  ),
                  MainContent(left: _sliderWidth, right: 0, top: 0, bottom: 0),
                  Positioned(
                    left: _sliderWidth - 10,
                    width: 20,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        _sliderWidth += details.delta.dx;
                        // 核心修改：只有悬停状态下才执行拖动逻辑
                        if (_isHovering) {
                          setState(() {
                            double screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            // 对_sliderWidth进行边界限制
                            _sliderWidth = _sliderWidth.clamp(
                              250.0,
                              screenWidth - 250.0,
                            );
                          });
                        }
                      },
                      child: MouseRegion(
                        // 可选：设置鼠标指针样式，提供视觉提示
                        cursor: SystemMouseCursors.resizeLeftRight,
                        onEnter: (event) {
                          // 鼠标进入时，激活悬停状态
                          setState(() {
                            _isHovering = true;
                          });
                        },
                        onExit: (event) {
                          // 鼠标离开时，取消悬停状态
                          setState(() {
                            _isHovering = false;
                          });
                        },
                        child: Container(
                          // 可选：根据悬停状态改变颜色，提供更明显的反馈
                          color: _isHovering
                              ? Color.fromRGBO(255, 0, 0, 0.8) // 悬停时更醒目的颜色
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
    );
  }
}
