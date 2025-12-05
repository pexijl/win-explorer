import 'dart:async';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/foundation.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';

/// 树形结构节点
class SidebarTreeNode extends TreeNode<AppDirectory> {
  SidebarTreeNode({required AppDirectory data})
    : super(data: data, key: data.path);

  Future<void> loadChildren() async {
    final directory = data;
    if (directory == null) return;
    final subdirectories = await directory.getSubdirectories(recursive: false);
    addAll(subdirectories.map((s) => SidebarTreeNode(data: s)));
  }
}
