import 'package:flutter/material.dart';
import 'package:win_explorer/data/services/win32_drive_service.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_view.dart';

class Sidebar extends StatefulWidget {
  final double left;
  final double right;
  final double top;
  final double bottom;
  final Function(AppDirectory) onDirectorySelected;

  const Sidebar({
    super.key,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.onDirectorySelected,
  });

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
      left: widget.left,
      right: widget.right,
      top: widget.top,
      bottom: widget.bottom,
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
