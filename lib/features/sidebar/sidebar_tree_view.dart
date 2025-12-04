import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
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
  String? _selectedNodeId;

  /// 树形结构
  List<TreeSliverNode<SidebarTreeNode>> _tree = [];

  /// 树形结构控制器
  final TreeSliverController _treeController = TreeSliverController();

  /// 记录对节点的订阅回调, 用于在节点变更时进行局部刷新
  final Map<SidebarTreeNode, VoidCallback> _nodeListeners = {};

  @override
  void initState() {
    super.initState();
    _buildTree(); // 构建树形结构
  }

  @override
  void didUpdateWidget(covariant SidebarTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.drives, widget.drives)) {
      _buildTree();
    }
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

    _subscribeToTreeNodesFromTree(_tree);
  }

  /// 局部更新: 仅更新发生变化的节点对应的 `TreeSliverNode`
  void _onNodeChanged(SidebarTreeNode changedNode) {
    if (changedNode.isPlaceholder) return; // 跳过占位符节点
    bool updated = false;

    // 根据 content 创建一个新的 [TreeSliverNode]
    TreeSliverNode<SidebarTreeNode> buildNodeFromContent(
      SidebarTreeNode content,
    ) {
      List<TreeSliverNode<SidebarTreeNode>> childrenNodes = [];
      if (content.children != null) {
        childrenNodes = _mapNodes(content.children!);
      } else if (content.hasChildren) {
        childrenNodes = [
          TreeSliverNode(
            SidebarTreeNode(
              label: 'Loading...',
              appDirectory: AppDirectory(''),
              isPlaceholder: true,
            ),
          ),
        ];
      }
      return TreeSliverNode(
        content,
        children: childrenNodes,
        expanded: content.isExpanded,
      );
    }

    // 在节点列表中找到并替换对应 content 的节点
    bool replaceNodeInList(
      List<TreeSliverNode<SidebarTreeNode>> nodes,
      SidebarTreeNode content,
      TreeSliverNode<SidebarTreeNode> newNode,
    ) {
      for (var i = 0; i < nodes.length; i++) {
        final n = nodes[i];
        if (n.content == content) {
          // 取消订阅旧子树
          _unsubscribeTreeSliverNode(n);
          // 替换
          nodes[i] = newNode;
          updated = true;
          return true;
        }
        if (replaceNodeInList(n.children, content, newNode)) return true;
      }
      return false;
    }

    final newNode = buildNodeFromContent(changedNode);
    replaceNodeInList(_tree, changedNode, newNode);
    if (updated) {
      // 订阅新的节点树
      _subscribeToTreeNodesFromList([newNode]);
      setState(() {});
    }
  }

  /// 取消订阅某个 `TreeSliverNode` 及其子树
  void _unsubscribeTreeSliverNode(TreeSliverNode<SidebarTreeNode> node) {
    final content = node.content;
    if (_nodeListeners.containsKey(content)) {
      content.removeListener(_nodeListeners[content]!);
      _nodeListeners.remove(content);
    }
    for (final c in node.children) {
      _unsubscribeTreeSliverNode(c);
    }
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
              isPlaceholder: true,
            ),
          ),
        ];
      }

      return TreeSliverNode(
        node,
        children: childrenNodes,
        expanded: node.isExpanded,
      );
    }).toList();
  }

  /// 订阅给定节点以及其子节点的变更通知, 并记录回调以便取消订阅
  void _subscribeToTreeNodesFromList(
    List<TreeSliverNode<SidebarTreeNode>> nodes,
  ) {
    for (final node in nodes) {
      final content = node.content;
      // 对于占位符节点不订阅
      if (content.isPlaceholder) continue;
      if (!_nodeListeners.containsKey(content)) {
        void listener() => _onNodeChanged(content);
        content.addListener(listener);
        _nodeListeners[content] = listener;
      }
      if (node.children.isNotEmpty) {
        _subscribeToTreeNodesFromList(node.children);
      }
    }
  }

  /// 从现有树结构订阅所有节点
  void _subscribeToTreeNodesFromTree(
    List<TreeSliverNode<SidebarTreeNode>> tree,
  ) {
    _unsubscribeAll();
    _subscribeToTreeNodesFromList(tree);
  }

  /// 取消订阅所有节点
  void _unsubscribeAll() {
    _nodeListeners.forEach((node, listener) {
      node.removeListener(listener);
    });
    _nodeListeners.clear();
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
                selectedNodeId: _selectedNodeId,
                onNodeSelected: (nodeId) {
                  setState(() {
                    _selectedNodeId = nodeId;
                  });
                  widget.onNodeSelected?.call(content.appDirectory);
                },
                onNodeChanged: (changedNode) => _onNodeChanged(changedNode),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _unsubscribeAll();
    // TreeSliverController doesn't expose dispose API
    super.dispose();
  }
}
