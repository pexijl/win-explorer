import 'package:flutter/material.dart';
import 'package:win_explorer/data/services/win32_drive_service.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_view.dart';

class Sidebar extends StatefulWidget {
  final double _left;
  final double _right;
  final double _top;
  final double _bottom;
  final Function(AppDirectory) onDirectorySelected;

  const Sidebar({
    super.key,
    required double left,
    required double right,
    required double top,
    required double bottom,
    required this.onDirectorySelected,
  }) : _left = left,
       _right = right,
       _top = top,
       _bottom = bottom;
  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final List<AppDirectory> rootDirectories = [];

  @override
  void initState() {
    super.initState();
    _getRootDirectories();
  }

  void _getRootDirectories() {
    final drives = Win32DriveService().getSystemDrives();
    rootDirectories.addAll(
      drives.map((drive) {
        return AppDirectory(path: drive.mountPoint, name: drive.name);
      }),
    );
  }

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
        child: SidebarTreeView(
          rootDirectories: rootDirectories,
          onNodeSelected: widget.onDirectorySelected,
        ),
      ),
    );
  }
}
