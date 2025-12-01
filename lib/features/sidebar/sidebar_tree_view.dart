import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node_widget.dart';

class SidebarTreeView extends StatefulWidget {
  const SidebarTreeView({super.key});

  @override
  State<SidebarTreeView> createState() => _SidebarTreeViewState();
}

class _SidebarTreeViewState extends State<SidebarTreeView> {
  List<Widget> treeItems = [];
  SidebarTreeNode? _selectedNode;

  List<Widget> _getTreeItems() {
    treeItems.clear();
    for (int i = 0; i < 100; i++) {
      final node = SidebarTreeNode(name: '目录项 $i', path: '路径 $i');
      treeItems.add(
        SidebarTreeNodeWidget(node: node, onTap: () => _handleNodeTap(node)),
      );
    }
    return treeItems;
  }

  void _handleNodeTap(SidebarTreeNode tappedNode) {
    setState(() {
      // 取消之前选中项
      _selectedNode?.unselect();

      // 设置新选中项
      tappedNode.select();
      _selectedNode = tappedNode;
    });
  }

  @override
  void initState() {
    super.initState();
    _getTreeItems();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Column(mainAxisSize: MainAxisSize.min, children: treeItems),
    );
  }
}
