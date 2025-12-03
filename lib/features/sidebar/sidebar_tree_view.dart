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
  // 记录请求的扩展（来自子节点）并在树更新后处理
  final Map<String, bool> _requestedExpansions = {};

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
    setState(() {
      _tree = _mapNodes(_tree.map((e) => e.content).toList());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_requestedExpansions.isEmpty) return;
      debugPrint(
        'Processing requestedExpansion changes: $_requestedExpansions',
      );
      _requestedExpansions.forEach((id, expanded) {
        final target = _findTreeNodeByContentId(id, _tree);
        if (target != null) {
          debugPrint('Found target for $id expanded=$expanded');
          if (expanded) {
            _treeController.expandNode(target);
          } else {
            _treeController.collapseNode(target);
          }
        } else {
          debugPrint('Target not found for $id');
        }
      });
      _requestedExpansions.clear();
      // rebuild to pick up controller animation changes
      setState(() {});
    });
  }

  TreeSliverNode<SidebarTreeNode>? _findTreeNodeByContentId(
    String id,
    List<TreeSliverNode<SidebarTreeNode>> nodes,
  ) {
    for (final n in nodes) {
      final content = n.content;
      if (content.id == id) return n;
      if (n.children.isNotEmpty) {
        final found = _findTreeNodeByContentId(id, n.children);
        if (found != null) return found;
      }
    }
    return null;
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
            final isExpanded = _treeController.isExpanded(node);
            return SidebarTreeNodeTile(
              key: ValueKey(content.id),
              node: content,
              isExpanded: isExpanded,
              selectedNode: _selectedNode,
              onNodeSelected: (n) {
                setState(() {
                  _selectedNode = n;
                });
                widget.onNodeSelected?.call(n.appDirectory);
              },
              onNodeChanged: _updateTreeNodes,
              onExpansionChanged: (isExpanded) {
                // `isExpanded` 是我们刚从图块接收到的新展开状态。
                // 推迟应用展开/折叠，直到我们更新树数据
                // （这可以避免动画期间控制器与树的不匹配）。
                print('父接收 new isExpanded: $isExpanded');
                _requestedExpansions[content.id] = isExpanded;
              },
            );
          },
        ),
      ],
    );
  }
}
