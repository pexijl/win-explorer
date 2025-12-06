import 'dart:async';

import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/features/sidebar/sidebar_node_item.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

class SidebarTreeView extends StatefulWidget {
  final List<AppDirectory> rootDirectories;
  final Function(AppDirectory)? onNodeSelected;

  const SidebarTreeView({
    super.key,
    required this.rootDirectories,
    this.onNodeSelected,
  });

  @override
  State<SidebarTreeView> createState() => _SidebarTreeViewState();
}

class _SidebarTreeViewState extends State<SidebarTreeView> {
  String? _selectedNodePath;

  final _scrollController = ScrollController();

  SidebarTreeNode root = SidebarTreeNode(
    data: AppDirectory(path: ' ', name: '此电脑'),
    level: 0,
    children: [],
  );

  @override
  void initState() {
    super.initState();
    _initTree();
  }

  void _initTree() {
    for (var directory in widget.rootDirectories) {
      root.children!.add(
        SidebarTreeNode(data: directory, level: root.level + 1),
      );
    }
  }

  Future<void> _loadChildren(SidebarTreeNode node) async {
    AppDirectory directory = node.data;
    List<AppDirectory> subDirectories = await directory.getSubdirectories();
    node.children = subDirectories
        .map(
          (directory) =>
              SidebarTreeNode(data: directory, level: node.level + 1),
        )
        .toList();
  }

  Widget _buildParentNode(SidebarTreeNode node) {
    return SidebarNodeItem(
      node: node,
      path: _selectedNodePath,
      onToggleNode: (node) {
        node.isExpanded = !node.isExpanded;
        setState(() {});
      },
      onSelectNode: (path) {},
    );
  }

  Widget _buildChildNodes(SidebarTreeNode node) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: node.children?.length ?? 0,
      itemBuilder: (context, index) {
        return SidebarNodeItem(
          node: node.children![index],
          path: _selectedNodePath,
          onToggleNode: (node) {},
          onSelectNode: (path) {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              children: [
                _buildParentNode(root),
                if (root.children != null &&
                    root.children!.isNotEmpty &&
                    root.isExpanded)
                  _buildChildNodes(root),
              ],
            );
          },
        ),
      ],
    );
  }
}
