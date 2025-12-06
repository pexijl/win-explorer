import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    hasChildren: true,
  );

  @override
  void initState() {
    super.initState();
    _initTree();
  }

  Future<void> _initTree() async {
    for (var directory in widget.rootDirectories) {
      root.children.add(
        await SidebarTreeNode.create(data: directory, level: root.level + 1),
      );
    }
    setState(() {});
  }

  Future<void> _loadChildren(SidebarTreeNode node) async {
    try {
      AppDirectory directory = node.data;
      List<AppDirectory> subDirectories = await directory.getSubdirectories();
      List<Future<SidebarTreeNode>> futures = subDirectories
          .map(
            (subDirectory) => SidebarTreeNode.create(
              data: subDirectory,
              level: node.level + 1,
            ),
          )
          .toList();
      List<SidebarTreeNode> children = await Future.wait(futures);
      node.children.addAll(children);
      node.hasLoadedChildren = true;
      print("Loaded ${node.data.name} with ${node.children.length} children");
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _buildParentNode(SidebarTreeNode node) {
    return SidebarNodeItem(
      node: node,
      path: _selectedNodePath,
      onToggleNode: (node) {
        print('收到:切换 ${node.data.name}');
        if (!node.isExpanded && !node.hasLoadedChildren) {
          print('展开 ${node.data.name}');
          _loadChildren(node);
        }
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
      itemCount: node.children.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            _buildParentNode(node.children[index]),
            if (node.children[index].isExpanded)
              _buildChildNodes(node.children[index]),
          ],
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
                if (root.children.isNotEmpty && root.isExpanded)
                  _buildChildNodes(root),
              ],
            );
          },
        ),
      ],
    );
  }
}
