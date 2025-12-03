import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node_title.dart';

/// 树形结构侧边栏视图
class SidebarTreeView extends StatefulWidget {
  /// 盘符列表
  final List<Drive> drives;

  /// 节点选中回调
  final Function(AppDirectory)? onNodeSelected;

  /// 构造函数
  const SidebarTreeView({super.key, required this.drives, this.onNodeSelected});

  @override
  State<SidebarTreeView> createState() => _SidebarTreeViewState();
}

class _SidebarTreeViewState extends State<SidebarTreeView> {
  /// 当前选中的节点
  SidebarTreeNode? _selectedNode;

  /// 树形结构
  List<TreeSliverNode<SidebarTreeNode>> _tree = [];

  /// 树形结构控制器
  final TreeSliverController _treeController = TreeSliverController();

  @override
  void initState() {
    super.initState();
    _buildTree(); // 构建树形结构
  }

  /// 构建树形结构
  Future<void> _buildTree() async {
    // 构建根节点
    final List<SidebarTreeNode> roots = [];
    for (Drive drive in widget.drives) {
      roots.add(
        SidebarTreeNode(
          label: drive.name,
          appDirectory: AppDirectory(drive.mountPoint),
        ),
      );
    }

    setState(() {
      _tree = _mapNodes(roots); // 映射为树形结构
    });
  }

  /// 更新树形结构节点
  void _updateTreeNodes() {
    print('update tree nodes');
    setState(() {
      _tree = _mapNodes(_tree.map((e) => e.content).toList());
    });
    print('update tree nodes done $_tree');
  }

  /// 将 `SidebarTreeNode` 列表映射为 `TreeSliverNode<SidebarTreeNode>` 列表
  List<TreeSliverNode<SidebarTreeNode>> _mapNodes(List<SidebarTreeNode> nodes) {
    return nodes.map((node) {
      List<TreeSliverNode<SidebarTreeNode>> childrenNodes = [];
      if (node.children != null) {
        childrenNodes = _mapNodes(node.children!);
      } else if (node.hasChildren) {
        childrenNodes = [
          TreeSliverNode(
            SidebarTreeNode(
              label: 'Loading...',
              appDirectory: AppDirectory(''),
            ),
          ),
        ];
      }

      return TreeSliverNode(node, children: childrenNodes);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        TreeSliver<SidebarTreeNode>(
          tree: _tree,
          controller: _treeController,
          treeNodeBuilder: (context, node, animation) {
            final content = node.content as SidebarTreeNode;
            return ChangeNotifierProvider<SidebarTreeNode>.value(
              value: content,
              child: SidebarTreeNodeTile(
                node: content,
                selectedNode: _selectedNode,
                onNodeSelected: (n) {
                  setState(() {
                    _selectedNode = n;
                  });
                  widget.onNodeSelected?.call(n.appDirectory);
                },
                onNodeChanged: _updateTreeNodes,
              ),
            );
          },
        ),
      ],
    );
  }
}
