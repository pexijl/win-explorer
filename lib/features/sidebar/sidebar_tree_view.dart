import 'dart:async';

import 'package:animated_tree_view/animated_tree_view.dart';
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
  String? selectedNodeKey;

  final TreeNode<AppDirectory> _tree = TreeNode.root(
    data: AppDirectory(path: '/root', name: '此电脑'),
  );

  @override
  void initState() {
    super.initState();
    _initTree();
  }

  void _initTree() {
    _tree.addAll(
      widget.rootDirectories.map(
        (directory) => TreeNode(data: directory, key: '0${directory.id}'),
      ),
    );
  }

  Future<void> _loadChildren(TreeNode<AppDirectory> node) async {
    final directory = node.data;
    if (directory == null) return;
    final subdirectories = await directory.getSubdirectories(recursive: false);
    print(subdirectories);
    node.addAll(
      subdirectories.map(
        (directory) =>
            TreeNode(data: directory, key: '${node.level}${directory.id}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverTreeView.simple(
          tree: _tree,
          indentation: const Indentation(),
          expansionIndicatorBuilder: (context, node) {
            return ChevronIndicator.rightDown(
              tree: node,
              alignment: Alignment.centerLeft,
              color: Colors.grey[700],
            );
          },
          builder: (context, node) {
            return SidebarNodeItem(
              node: node,
              selectedNodeKey: selectedNodeKey,
              onToggleNode: (node) {
                print('toggle node: $node');
              },
              onSelectNode: (path) {
                print('选中节点：$path');
              },
            );
          },
          onItemTap: (node) {
            print('展开/折叠：${node.key}');
            _loadChildren(node);
          },
        ),
      ],
    );
  }
}
