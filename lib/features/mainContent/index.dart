import 'package:flutter/material.dart';

class MainContent extends StatefulWidget {
  final double _left;
  final double _right;
  final double _top;
  final double _bottom;

  const MainContent({
    super.key,
    required double left,
    required double right,
    required double top,
    required double bottom,
  }) : _left = left,
       _right = right,
       _top = top,
       _bottom = bottom;

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget._left,
      right: widget._right,
      top: widget._top,
      bottom: widget._bottom,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: const Center(child: Text('Main Content Area')),
      ),
    );
  }
}
