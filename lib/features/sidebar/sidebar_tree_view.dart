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
    _tree = TreeNode.root(
      data: AppDirectory(path: 'root', name: 'Root'),
    );
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
        await _loadChildren(node);
        await _loadGrandChildren(node);
        _tree.add(node);
      }
    }
    // if (mounted) setState(() {});
  }

  Future<void> _loadChildren(TreeNode<AppDirectory> node) async {
    final directory = node.data;
    if (directory == null) return;
    final subdirectories = await directory.getSubdirectories(recursive: false);
    for (var subdir in subdirectories) {
      final key = _generateKey(subdir.path);
      if (!node.children.containsKey(key)) {
        final childNode = TreeNode<AppDirectory>(key: key, data: subdir);
        node.add(childNode);
      }
    }
  }

  Future<void> _loadGrandChildren(TreeNode<AppDirectory> node) async {
    for (var child in node.childrenAsList) {
      await _loadChildren(child as TreeNode<AppDirectory>);
    }
  }

  Future<void> _loadGreatGrandChildren(TreeNode<AppDirectory> node) async {
    for (var child in node.childrenAsList) {
      final childNode = child as TreeNode<AppDirectory>;
      await _loadChildren(childNode);
      for (var grandChild in childNode.childrenAsList) {
        await _loadChildren(grandChild as TreeNode<AppDirectory>);
      }
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
            await _loadGreatGrandChildren(node);
            // setState(() {});
          },
          expansionBehavior: ExpansionBehavior.none,
        ),
      ],
    );
  }
}
