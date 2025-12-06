import 'dart:async';

import 'package:win_explorer/domain/entities/app_directory.dart';

/// 树形结构节点
class SidebarTreeNode {
  final AppDirectory data;
  final int level;
  bool isExpanded;

  List<SidebarTreeNode>? children;

  bool get hasChildren => children != null && children!.isNotEmpty;

  SidebarTreeNode({
    required this.data,
    required this.level,
    this.isExpanded = false,
    this.children,
  });

  @override
  toString() {
    return 'SidebarTreeNode{data: $data, level: $level, isExpanded: $isExpanded, children: $children}';
  }
}
