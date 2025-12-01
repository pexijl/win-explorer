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
  List<SidebarTreeNode> nodes = [];
  SidebarTreeNode? _selectedNode;

  void _handleNodeTap(SidebarTreeNode tappedNode) {
    setState(() {
      _selectedNode = tappedNode;
    });
  }

  @override
  void initState() {
    super.initState();
    // 初始化节点数据
    for (int i = 0; i < 100; i++) {
      nodes.add(SidebarTreeNode(name: '目录项 $i', path: '路径 $i'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
