import 'dart:core';

import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node_widget.dart';

class SidebarTreeView extends StatefulWidget {
  final List<Drive> drives;
  /// Callback returns the selected AppDirectory for the chosen node
  final Function(AppDirectory)? onNodeSelected;

  const SidebarTreeView({super.key, required this.drives, this.onNodeSelected});

  @override
  State<SidebarTreeView> createState() => _SidebarTreeViewState();
}

class _SidebarTreeViewState extends State<SidebarTreeView> {
  SidebarTreeNode? _selectedNode;
  final List<SidebarTreeNode> _tree = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buildTree();
  }

  @override
  void didUpdateWidget(SidebarTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.drives != oldWidget.drives) {
      _buildTree();
    }
  }

  Future<void> _buildTree() async {
    setState(() {
      _isLoading = true;
    });
    _tree.clear();
    for (Drive drive in widget.drives) {
      _tree.add(SidebarTreeNode.fromDrive(drive: drive));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // We're using SidebarTreeNode & SidebarTreeNodeWidget to manage
  // expansion/collapse and selection. The previous TreeSliver
  // implementation intercepted taps and caused toggle not to fire.

  Widget _buildList() {
    return ListView(
      padding: EdgeInsets.zero,
      children: _tree.map((node) => SidebarTreeNodeWidget(
        node: node,
        selectedNode: _selectedNode,
        onNodeSelected: (n) {
          setState(() {
            _selectedNode = n;
          });
          widget.onNodeSelected?.call(n.appDirectory);
        },
      )).toList(),
    );
  }

  // SidebarTreeNode handles loading children by itself, so we don't
  // need custom load logic here anymore.

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildList();
  }
}
