import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:win_explorer/data/services/win32_drive_service.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node_widget.dart';

class SidebarTreeView extends StatefulWidget {
  const SidebarTreeView({super.key});

  @override
  State<SidebarTreeView> createState() => _SidebarTreeViewState();
}

class _SidebarTreeViewState extends State<SidebarTreeView> {
  List<SidebarTreeNode> nodes = [];
  SidebarTreeNode? _selectedNode;

  void _handleNodeTap(SidebarTreeNode tappedNode) {
    setState(() {
      _selectedNode = tappedNode;
    });
  }

  void _getNodes() async {
    List<Drive> drives = Win32DriveService().getSystemDrives();
    nodes = drives.map((drive) => SidebarTreeNode.fromDrive(drive: drive)).toList();
  }

  @override
  void initState() {
    super.initState();
    _getNodes();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: nodes
            .map(
              (node) => SidebarTreeNodeWidget(
                node: node,
                isSelected: _selectedNode == node,
                onTap: () => _handleNodeTap(node),
              ),
            )
            .toList(),
      ),
    );
  }
}
