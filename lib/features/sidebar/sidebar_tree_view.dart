import 'dart:async';

import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/features/sidebar/sidebar_node_item.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

class SidebarTreeView extends StatefulWidget {
  /// 根目录
  final List<AppDirectory> rootDirectories;
  /// 点击节点回调
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
  /// 选中的节点路径
  String? _selectedNodePath;
  /// 滚动控制器
  final _scrollController = ScrollController();
  /// 树根
  SidebarTreeNode root = SidebarTreeNode(
    data: AppDirectory(path: '此电脑', name: '此电脑'),
    level: 0,
    hasChildren: true,
  );

  /// 初始化
  @override
  void initState() {
    super.initState();
    _initTree(); // 初始化树
  }

  /// 销毁
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 初始化树
  Future<void> _initTree() async {
    for (var directory in widget.rootDirectories) {
      root.children.add(
        await SidebarTreeNode.create(data: directory, level: root.level + 1),
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// 加载子节点
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
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 构建父节点
  Widget _buildParentNode(SidebarTreeNode node) {
    return SidebarNodeItem(
      node: node,
      path: _selectedNodePath,
      onToggleNode: (node) {
        if (!node.isExpanded && !node.hasLoadedChildren) {
          _loadChildren(node); // 当节点折叠时且没有加载过子节点时加载子节点
        }
        node.isExpanded = !node.isExpanded; // 切换节点展开状态
        setState(() {});
      },
      onSelectNode: (directory) {
        _selectedNodePath = directory.path;
        widget.onNodeSelected?.call(directory);
        setState(() {});
      },
    );
  }

  /// 收集可见节点
  List<SidebarTreeNode> _collectVisibleNodes() {
    /// 可见节点列表
    final visibleNodes = <SidebarTreeNode>[];

    /// 访问节点
    void visit(SidebarTreeNode node) {
      visibleNodes.add(node);
      if (!node.isExpanded) return;

      for (final child in node.children) {
        visit(child);
      }
    }

    visit(root);
    return visibleNodes;
  }

  @override
  Widget build(BuildContext context) {
    final visibleNodes = _collectVisibleNodes();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverList.builder(
          itemCount: visibleNodes.length,
          itemBuilder: (context, index) {
            final node = visibleNodes[index];
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(-0.05, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(node.data.path),
                child: _buildParentNode(node),
              ),
            );
          },
        ),
      ],
    );
  }
}
