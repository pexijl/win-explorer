import 'package:flutter/material.dart';
import 'package:win_explorer/data/services/win32_drive_service.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_view.dart';

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
  List<Drive> drives = [];

  @override
  void initState() {
    super.initState();
    _getDrives();
  }

  void _getDrives() {
    drives = Win32DriveService().getSystemDrives();
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
        child: SidebarTreeView(),
      ),
    );
  }
}
