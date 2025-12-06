import 'dart:async';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/features/sidebar/sidebar_node_item.dart';

class SidebarTreeView extends StatefulWidget {
  final List<AppDirectory> rootDirectories;
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
  String? _selectedNodeKey;
  late final TreeNode<AppDirectory> _tree;

  AutoScrollController _scrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();
    _tree = TreeNode.root(data: AppDirectory(path: 'root', name: 'Root'));
    _initTree();
  }

  @override
  void didUpdateWidget(covariant SidebarTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rootDirectories != oldWidget.rootDirectories) {
      _tree.clear();
      _initTree();
    }
  }

  String _generateKey(String path) {
    return path.replaceAll('.', '{dot}');
  }

  Future<void> _initTree() async {
    for (var dir in widget.rootDirectories) {
      final key = _generateKey(dir.path);
      if (!_tree.children.containsKey(key)) {
        final node = TreeNode<AppDirectory>(key: key, data: dir);
        
        // 直接实现加载两层：子节点和孙节点
        try {
          final subdirectories = await dir.getSubdirectories(recursive: false);
          for (var subDir in subdirectories) {
            final subNode = TreeNode<AppDirectory>(key: _generateKey(subDir.path), data: subDir);
            
            // 加载孙节点
            try {
              final subSubDirs = await subDir.getSubdirectories(recursive: false);
              for (var subSubDir in subSubDirs) {
                final grandChild = TreeNode<AppDirectory>(key: _generateKey(subSubDir.path), data: subSubDir);
                grandChild.expansionNotifier.value = false;
                subNode.add(grandChild);
              }
            } catch (e) {
              // 忽略孙节点加载错误
            }

            subNode.expansionNotifier.value = false;
            node.add(subNode);
          }
        } catch (e) {
          debugPrint('Error loading children for ${dir.path}: $e');
        }

        node.expansionNotifier.value = false;
        _tree.add(node);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadChildren(TreeNode<AppDirectory> node) async {
    final directory = node.data;
    if (directory == null) return;

    try {
      // 仅加载node的孙节点：遍历现有子节点，为每个子节点加载其子节点（孙节点）
      for (var child in node.children.values) {
        final childNode = child as TreeNode<AppDirectory>;
        if (childNode.children.isEmpty) {
          final childDir = childNode.data;
          if (childDir != null) {
            try {
              final subSubDirs = await childDir.getSubdirectories(recursive: false);
              for (var subSubDir in subSubDirs) {
                final grandChild = TreeNode<AppDirectory>(key: _generateKey(subSubDir.path), data: subSubDir);
                grandChild.expansionNotifier.value = false;
                childNode.add(grandChild);
              }
              // 确保子节点在添加孙节点后保持折叠状态
              childNode.expansionNotifier.value = false;
            } catch (e) {
              // 忽略孙节点加载错误
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading grandchildren for ${directory.path}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverTreeView.simple(
          tree: _tree,
          scrollController: _scrollController,
          showRootNode: true,
          builder: (context, node) {
            return SidebarNodeItem(
              node: node,
              selectedNodeKey: _selectedNodeKey,
              onToggleNode: (node) {},
              onSelectNode: (path) {
                setState(() {
                  _selectedNodeKey = path;
                });
                if (node.data != null) {
                  widget.onNodeSelected?.call(node.data!);
                }
              },
            );
          },
          expansionIndicatorBuilder: (context, node) {
            return ChevronIndicator.rightDown(
              tree: node,
              alignment: Alignment.centerLeft,
              color: Colors.grey[700],
            );
          },
          indentation: const Indentation(),
          onItemTap: (node) async {
            await _loadChildren(node);
            // setState(() {});
          },
          expansionBehavior : ExpansionBehavior.none,
        ),
      ],
    );
  }
}
