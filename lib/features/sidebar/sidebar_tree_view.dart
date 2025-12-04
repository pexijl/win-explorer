import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/features/sidebar/sidebar_node_item.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

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

  /// 防止重复加载同一节点
  final Map<String, Future<void>> _pendingLoads = {};

  /// 记录最近切换（展开/收起）的节点时间戳，用于在短时间内忽略对其子节点的选中点击
  final Map<String, DateTime> _recentlyToggled = {};

  /// 在切换节点后，忽略后续选择事件的时间窗口
  final Duration _ignoreSelectionDuration = const Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _buildTree(); // 构建树形结构
  }

  @override
  void didUpdateWidget(covariant SidebarTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.rootDirectories, widget.rootDirectories)) {
      _buildTree();
      setState(() {});
    }
  }

  void _buildTree() {
    _tree.clear();
    for (final directory in widget.rootDirectories) {
      _tree.add(_createTreeNode(directory, depth: 0));
    }
  }

  TreeSliverNode<SidebarTreeNode> _createTreeNode(
    AppDirectory directory, {
    required int depth,
  }) {
    return TreeSliverNode(
      SidebarTreeNode(
        label: directory.name,
        appDirectory: directory,
        depth: depth,
      ),
    );
  }

  bool _shouldLoad(TreeSliverNode<SidebarTreeNode> node) {
    if (node.children.isEmpty) return true;
    return node.children.every((child) => child.content.isPlaceholder);
  }

  Future<void> _loadChildren(TreeSliverNode<SidebarTreeNode> node) {
    final nodeId = node.content.id;
    final existing = _pendingLoads[nodeId];
    if (existing != null) {
      return existing;
    }
    final future = _hydrateNode(node);
    _pendingLoads[nodeId] = future;
    future.whenComplete(() => _pendingLoads.remove(nodeId));
    return future;
  }

  Future<void> _hydrateNode(TreeSliverNode<SidebarTreeNode> node) async {
    final directory = node.content.appDirectory;
    node.content.markLoading(true);
    try {
      final subdirectories = await directory.getSubdirectories(recursive: false);
      if (!mounted) return;
      setState(() {
        node.children
          ..clear()
          ..addAll(
            subdirectories.map(
              (subdirectory) => _createTreeNode(
                subdirectory,
                depth: node.content.depth + 1,
              ),
            ),
          );
      });
      node.content.markHasChildren(subdirectories.isNotEmpty);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        node.children.clear();
      });
      node.content.markHasChildren(false);
    } finally {
      node.content.markLoading(false);
    }
  }

  void _showLoadingPlaceholder(TreeSliverNode<SidebarTreeNode> node) {
    node.children
      ..clear()
      ..add(
        TreeSliverNode(
          SidebarTreeNode(
            id: '${node.content.id}::loading',
            label: '加载中...',
            appDirectory: node.content.appDirectory,
            isPlaceholder: true,
            depth: node.content.depth + 1,
          ),
        ),
      );
  }

  void _onToggleNode(TreeSliverNode<SidebarTreeNode> node) {
    final expanding = !node.isExpanded;
    node.content.markExpanded(expanding);
    if (expanding && _shouldLoad(node)) {
      setState(() {
        _showLoadingPlaceholder(node);
      });
      unawaited(_loadChildren(node));
    }
    // 记录切换时间（父节点路径），之后在选择子节点时做忽略判断
    _recentlyToggled[node.content.appDirectory.path] = DateTime.now();
    Future.delayed(_ignoreSelectionDuration).then((_) {
      final recorded = _recentlyToggled[node.content.appDirectory.path];
      if (recorded != null && DateTime.now().difference(recorded) >= _ignoreSelectionDuration) {
        _recentlyToggled.remove(node.content.appDirectory.path);
      }
    });

    _treeController.toggleNode(node);
    setState(() {});
  }

  void _onSelectNode(SidebarTreeNode node) {
    // 如果选择的节点是在最近被切换（展开/收起）的某个节点的子节点，则忽略这次选择
    final childPath = node.appDirectory.path;
    for (final parentPath in _recentlyToggled.keys.toList()) {
      if (_isDescendant(parentPath, childPath)) {
        return; // 忽略快速点击子节点的问题
      }
    }
    if (_selectedNodeId == node.id) return;
    setState(() {
      _selectedNodeId = node.id;
    });
    widget.onNodeSelected?.call(node.appDirectory);
  }

  bool _isDescendant(String parentPath, String childPath) {
      // 移除末尾的路径分隔符（统一正斜杠/反斜杠）
      parentPath = parentPath.replaceAll(RegExp(r'[\\/]+$'), '');
      childPath = childPath.replaceAll(RegExp(r'[\\/]+$'), '');
    // 简单判断子路径是否以父路径为前缀，并且多出一个分隔符
    if (parentPath.isEmpty || childPath.isEmpty) return false;
    if (parentPath == childPath) return false;
    if (!childPath.startsWith(parentPath)) return false;
    if (childPath.length <= parentPath.length) return false;
    final sep = childPath[parentPath.length];
    return sep == '/' || sep == '\\';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        TreeSliver<SidebarTreeNode>(
          tree: _tree,
          controller: _treeController,
          treeNodeBuilder: (context, node, animation) {
            final sidebarNode = node as TreeSliverNode<SidebarTreeNode>;
            return ChangeNotifierProvider<SidebarTreeNode>.value(
              value: sidebarNode.content,
              child: SidebarNodeItem(
                node: sidebarNode,
                selectedNodeId: _selectedNodeId,
                onToggleNode: _onToggleNode,
                onSelectNode: _onSelectNode,
                animation: animation,
              ),
            );
          },
        ),
      ],
    );
  }
}
