import 'dart:core';

import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node_widget.dart';

class SidebarTreeView extends StatefulWidget {
  final List<Drive> drives;
  final Function(SidebarTreeNode)? onNodeSelected;

  const SidebarTreeView({
    super.key,
    required this.drives,
    this.onNodeSelected,
  });

  @override
  State<SidebarTreeView> createState() => _SidebarTreeViewState();
}

class _SidebarTreeViewState extends State<SidebarTreeView> {
  List<SidebarTreeNode> nodes = [];
  SidebarTreeNode? _selectedNode;

  @override
  void initState() {
    super.initState();
    _initNodes();
  }

  @override
  void didUpdateWidget(SidebarTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drives != widget.drives) {
      _initNodes();
    }
  }

  void _initNodes() {
    nodes = widget.drives
        .map((drive) => SidebarTreeNode.fromDrive(drive: drive))
        .toList();
  }

  void _handleNodeSelected(SidebarTreeNode selectedNode) {
    setState(() {
      _selectedNode = selectedNode;
    });
    widget.onNodeSelected?.call(selectedNode);
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
                selectedNode: _selectedNode,
                onNodeSelected: _handleNodeSelected,
              ),
            )
            .toList(),
      ),
    );
  }
}
