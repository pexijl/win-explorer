import 'dart:core';

import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node_widget.dart';

class SidebarTreeView extends StatefulWidget {
  final List<Drive> drives;
  final Function(SidebarTreeNode)? onNodeSelected;

  const SidebarTreeView({super.key, required this.drives, this.onNodeSelected});

  @override
  State<SidebarTreeView> createState() => _SidebarTreeViewState();
}

class _SidebarTreeViewState extends State<SidebarTreeView> {
  TreeSliverNode<AppDirectory>? _selectedNode;
  final TreeSliverController controller = TreeSliverController();
  final List<TreeSliverNode<AppDirectory>> _tree = [];
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
      AppDirectory root = AppDirectory(drive.mountPoint);
      List<TreeSliverNode<AppDirectory>> subNodes =
          (await root.getSubdirectories(recursive: false)).map((subDir) {
            return TreeSliverNode<AppDirectory>(subDir);
          }).toList();
      TreeSliverNode<AppDirectory> node = TreeSliverNode<AppDirectory>(
        root,
        children: subNodes,
      );
      _tree.add(node);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _treeNodeBuilder(
    BuildContext context,
    TreeSliverNode<Object?> node,
    AnimationStyle animationStyle,
  ) {
    return TreeSliver.wrapChildToToggleNode(
      node: node,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 89, 180, 255),
          border: Border.all(color: Colors.black),
        ),
        height: 30,
        child: Row(
          children: [
            if (node.children.isNotEmpty) // Show expand icon when child nodes are not empty
              SizedBox(
                width: 24,
                child: Icon(
                  node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                ),
              ),
            Text((node.content as AppDirectory).name),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSlivers() {
    return [
      TreeSliver<AppDirectory>(
        tree: _tree,
        controller: controller,
        treeNodeBuilder: _treeNodeBuilder,
        onNodeToggle: (node) {

          setState(() {
            _selectedNode = node as TreeSliverNode<AppDirectory>?;
          });
        },
        treeRowExtentBuilder: (node, layoutDimensions) {
          return 30;
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return CustomScrollView(slivers: _buildSlivers());
  }

}
