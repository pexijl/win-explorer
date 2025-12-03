import 'dart:core';

import 'package:flutter/material.dart';
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
  /// 是否正在加载中
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buildTree(); // 构建树形结构
  }

  @override
  void didUpdateWidget(SidebarTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.drives != oldWidget.drives) {
      _buildTree();
    }
  }

  /// 构建树形结构
  Future<void> _buildTree() async {
    setState(() {
      _isLoading = true; // 设置加载中
    });
    
    // 构建根节点
    final List<SidebarTreeNode> roots = [];
    for (Drive drive in widget.drives) {
      roots.add(SidebarTreeNode.fromDrive(drive: drive));
    }
    
    setState(() {
      _tree = _mapNodes(roots); // 映射为树形结构
    });

    if (mounted) {
      // 设置加载完成
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 更新树形结构节点  
  void _updateTreeNodes() {
    setState(() {
      final roots = _tree.map((e) => e.content).toList();
      _tree = _mapNodes(roots);
    });
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
