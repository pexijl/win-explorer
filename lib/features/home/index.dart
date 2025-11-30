import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _sliderWidth = 250;
  double? _dragStartX;
  double? _initialWidth;
  double? _initialGlobalX;

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
              child: Row(
                children: [
                  GestureDetector(
                    onPanStart: (details) {
                      _dragStartX = details.localPosition.dx;
                      if (_dragStartX! > _sliderWidth - 10) {
                        _initialWidth = _sliderWidth;
                        _initialGlobalX = details.globalPosition.dx;
                      }
                    },
                    onPanUpdate: (details) {
                      if (_initialWidth != null && _initialGlobalX != null) {
                        setState(() {
                          double screenWidth = MediaQuery.of(
                            context,
                          ).size.width;
                          double deltaX =
                              details.globalPosition.dx - _initialGlobalX!;
                          _sliderWidth = (_initialWidth! + deltaX).clamp(
                            250,
                            screenWidth - 250,
                          );
                        });
                      }
                    },
                    onPanEnd: (details) {
                      _dragStartX = null;
                      _initialWidth = null;
                      _initialGlobalX = null;
                    },
                    child: Container(
                      width: _sliderWidth,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Sidebar')),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: const Center(child: Text('Main Content Area')),
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
