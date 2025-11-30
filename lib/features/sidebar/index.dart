import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {

  final double _sliderWidth;

  const Sidebar({super.key, required double sliderWidth}) : _sliderWidth = sliderWidth;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      width: widget._sliderWidth,
      top: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: const Center(child: Text('Sidebar')),
      ),
    );
  }
}
