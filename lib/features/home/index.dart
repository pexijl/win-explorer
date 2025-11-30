import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _sliderWidth = 250;

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
                    onPanUpdate: (details) {
                      setState(() {
                        _sliderWidth += details.delta.dx;
                      });
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
