import 'dart:core';

import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node_title.dart';

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
  List<TreeSliverNode<SidebarTreeNode>> _tree = [];
  final TreeSliverController _treeController = TreeSliverController();
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
    
    final List<SidebarTreeNode> roots = [];
    for (Drive drive in widget.drives) {
      roots.add(SidebarTreeNode.fromDrive(drive: drive));
    }
    
    setState(() {
      _tree = _mapNodes(roots);
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateTreeNodes() {
    setState(() {
      final roots = _tree.map((e) => e.content).toList();
      _tree = _mapNodes(roots);
    });
  }

  List<TreeSliverNode<SidebarTreeNode>> _mapNodes(List<SidebarTreeNode> nodes) {
    return nodes.map((node) {
      List<TreeSliverNode<SidebarTreeNode>> childrenNodes = [];
      if (node.children != null) {
        childrenNodes = _mapNodes(node.children!);
      } else if (node.hasChildren) {
        childrenNodes = [
          TreeSliverNode(
            SidebarTreeNode(
              appDirectory: AppDirectory('Loading...'),
              name: 'Loading...',
            ),
          )
        ];
      }

      return TreeSliverNode(
        node,
        expanded: node.isExpanded,
        children: childrenNodes,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return CustomScrollView(
      slivers: [
        TreeSliver<SidebarTreeNode>(
          tree: _tree,
          controller: _treeController,
          treeNodeBuilder: (context, node, animation) {
            return SidebarTreeNodeTile(
              node: node.content as SidebarTreeNode,
              selectedNode: _selectedNode,
              onNodeSelected: (n) {
                setState(() {
                  _selectedNode = n;
                });
                widget.onNodeSelected?.call(n.appDirectory);
              },
              onNodeChanged: _updateTreeNodes,
            );
          },
        ),
      ],
    );
  }
}
