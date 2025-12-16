import 'dart:async';

import 'package:flutter/material.dart';
import 'package:win_explorer/entities/app_directory.dart';
import 'package:win_explorer/components/Sidebar/sidebar_node_item.dart';
import 'package:win_explorer/components/Sidebar/sidebar_tree_node.dart';
import 'package:win_explorer/services/file_system_service.dart';

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
  static const String _virtualThisComputerPath = '此电脑';

  /// 选中的节点路径
  String? _selectedNodePath;

  /// 滚动控制器
  final _scrollController = ScrollController();

  StreamSubscription<FileSystemChange>? _fsSub;

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

    _fsSub = FileSystemService.instance.changes.listen((change) {
      if (change.type == FileSystemChangeType.directoryChildrenChanged) {
        if (change.directoryPath == _virtualThisComputerPath) return;
        () async {
          await _refreshDirectoryChildren(change.directoryPath);
        }();
      }
    });
  }

  /// 销毁
  @override
  void dispose() {
    _fsSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  SidebarTreeNode? _findNodeByPath(String path) {
    SidebarTreeNode? found;

    void visit(SidebarTreeNode node) {
      if (found != null) return;
      if (node.data.path == path) {
        found = node;
        return;
      }
      for (final child in node.children) {
        visit(child);
      }
    }

    visit(root);
    return found;
  }

  Future<void> _refreshDirectoryChildren(String directoryPath) async {
    if (directoryPath == _virtualThisComputerPath) return;

    final node = _findNodeByPath(directoryPath);
    if (node == null) return;
    if (node.data.path == _virtualThisComputerPath) return;

    try {
      final subDirectories = await node.data.getSubdirectories(
        recursive: false,
      );
      final hasChildren = subDirectories.isNotEmpty;

      node.hasChildren = hasChildren;

      // 目录已经没有子目录了：清空缓存
      if (!hasChildren) {
        node.children.clear();
        node.hasLoadedChildren = false;
        node.isExpanded = false;
        if (mounted) setState(() {});
        return;
      }

      // 没加载过子节点：只更新 hasChildren，确保显示展开/折叠图标
      if (!node.hasLoadedChildren) {
        if (mounted) setState(() {});
        return;
      }

      // 已加载过：同步 children（新增/删除）
      final desiredPaths = subDirectories.map((d) => d.path).toSet();
      node.children.removeWhere((c) => !desiredPaths.contains(c.data.path));

      final existingPaths = node.children.map((c) => c.data.path).toSet();
      final toAdd = subDirectories.where(
        (d) => !existingPaths.contains(d.path),
      );
      final futures = toAdd
          .map(
            (dir) => SidebarTreeNode.create(data: dir, level: node.level + 1),
          )
          .toList();

      if (futures.isNotEmpty) {
        final newChildren = await Future.wait(futures);
        node.children.addAll(newChildren);
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 初始化树
  Future<void> _initTree() async {
    for (var directory in widget.rootDirectories) {
      root.children.add(
        await SidebarTreeNode.create(data: directory, level: root.level + 1),
      );
    }

    // “此电脑”是虚拟节点，子节点（盘符）由我们直接构建。
    // 标记为已加载，避免展开时再去访问文件系统。
    root.hasLoadedChildren = true;

    if (mounted) {
      setState(() {});
    }
  }

  /// 加载子节点
  Future<void> _loadChildren(SidebarTreeNode node) async {
    // “此电脑”是虚拟节点，不从文件系统加载子节点。
    if (node.data.path == _virtualThisComputerPath) {
      node.hasLoadedChildren = true;
      if (mounted) setState(() {});
      return;
    }

    try {
      AppDirectory directory = node.data;
      List<AppDirectory> subDirectories = await directory.getSubdirectories();

      // 每次加载都刷新 hasChildren，避免首次为空后状态不更新
      node.hasChildren = subDirectories.isNotEmpty;

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
