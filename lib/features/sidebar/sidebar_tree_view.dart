import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/features/sidebar/sidebar_node_item.dart';

/// 树形结构侧边栏视图
class SidebarTreeView extends StatefulWidget {
  /// 根目录列表
  final List<AppDirectory> rootDirectories;

  /// 节点选中回调
  final Function(AppDirectory)? onNodeSelected;

  /// 构造函数
  const SidebarTreeView({
    super.key,
    required this.rootDirectories,
    this.onNodeSelected,
  });
  @override
  State<SidebarTreeView> createState() => _SidebarTreeViewState();
}

class _SidebarTreeViewState extends State<SidebarTreeView> {
  /// 当前选中的节点
  String? _selectedNodeId;

  /// 树形结构
  final List<TreeSliverNode<SidebarTreeNode>> _tree = [];

  /// 树形结构控制器
  final TreeSliverController _treeController = TreeSliverController();

  @override
  void initState() {
    super.initState();
    _buildTree(); // 构建树形结构
  }

  void _buildTree() {
    _tree.clear();
    for (final directory in widget.rootDirectories) {
      _tree.add(
        TreeSliverNode(
          SidebarTreeNode(label: directory.name, appDirectory: directory),
        ),
      );
    }
  }

  Future<void> _loadChildren(TreeSliverNode<SidebarTreeNode> node) async {
    AppDirectory directory = (node.content).appDirectory;
    List<AppDirectory> subdirectories = await directory.getSubdirectories();
    node.children.clear();
    node.children.addAll(
      subdirectories.map((subdirectory) {
        return TreeSliverNode(
          SidebarTreeNode(label: subdirectory.name, appDirectory: subdirectory),
        );
      }),
    );
  }

  Future<void> _onToggleNode(TreeSliverNode<SidebarTreeNode> node) async {
    print('父接收到节点: ${node.content.label}');
    // 当节点折叠 + 有子节点 + 还没加载子节点时，加载子节点
    if (!node.isExpanded && node.content.hasChildren && node.children.isEmpty) {
      await _loadChildren(node);
    }
    _treeController.toggleNode(node);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        TreeSliver<SidebarTreeNode>(
          tree: _tree,
          controller: _treeController,
          treeNodeBuilder: (context, node, animation) {
            return SidebarNodeItem(
              node: node as TreeSliverNode<SidebarTreeNode>,
              selectedNodeId: _selectedNodeId,
              onToggleNode: (node) => _onToggleNode(node),
              onSelectNode: (node) {
                setState(() {
                  _selectedNodeId = node.id;
                });
                widget.onNodeSelected?.call(node.appDirectory);
              },
            );
          },
        ),
      ],
    );
  }
}
