import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _sliderWidth = 250;
  double get screenWidth => MediaQuery.sizeOf(context).width;
  double get screenHeight => MediaQuery.sizeOf(context).height;
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
                  Positioned(
                    left: 0,
                    width: _sliderWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: const Center(child: Text('Sidebar')),
                    ),
                  ),
                  Positioned(
                    left: _sliderWidth,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: const Center(child: Text('Main Content Area')),
                    ),
                  ),
                  Positioned(
                    left: _sliderWidth - 10,
                    width: 20,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _sliderWidth += details.delta.dx;
                          double screenWidth = MediaQuery.of(
                            context,
                          ).size.width;
                          if (_sliderWidth < 250) {
                            _sliderWidth = 250;
                          } else if (_sliderWidth > screenWidth - 250) {
                            _sliderWidth = screenWidth - 250;
                          }
                        });
                      },
                      child: Container(color: Color.fromRGBO(0, 0, 255, 0.5)),
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
