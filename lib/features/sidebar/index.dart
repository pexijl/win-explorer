import 'package:flutter/material.dart';
import 'package:win_explorer/data/services/win32_drive_service.dart';

class Sidebar extends StatefulWidget {
  final double _left;
  final double _right;
  final double _top;
  final double _bottom;

  const Sidebar({
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
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  List<String> drives = [];

  @override
  void initState() {
    super.initState();
    _getDrives();
  }

  void _getDrives() {
    drives = Win32Service().getDriveList();
    for (int i = 0; i < drives.length; i++) {
      if (drives[i].endsWith('\\')) {
        drives[i] = drives[i].substring(0, drives[i].length - 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget._left,
      right: widget._right,
      top: widget._top,
      bottom: widget._bottom,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: ListView.builder(
          itemCount: drives.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(drives[index]));
          },
        ),
      ),
    );
  }
}
