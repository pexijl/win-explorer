import 'dart:async';

import 'package:win_explorer/entities/app_directory.dart';

/// 树形结构节点
class SidebarTreeNode {
  final AppDirectory data;
  final int level;
  bool isExpanded;
  bool hasChildren;
  bool hasLoadedChildren;
  final List<SidebarTreeNode> children = [];

  SidebarTreeNode({
    required this.data,
    required this.level,
    this.isExpanded = false,
    this.hasChildren = false,
    this.hasLoadedChildren = false,
  });

  /// 异步创建 SidebarTreeNode，检查是否有子节点
  static Future<SidebarTreeNode> create({
    required AppDirectory data,
    required int level,
    bool isExpanded = false,
    bool hasLoadedChildren = false,
  }) async {
    bool hasChildren = await data.hasSubdirectories();
    return SidebarTreeNode(
      data: data,
      level: level,
      isExpanded: isExpanded,
      hasChildren: hasChildren,
      hasLoadedChildren: hasLoadedChildren,
    );
  }

  @override
  String toString() {
    return 'SidebarTreeNode{data: $data, level: $level, isExpanded: $isExpanded, hasChildren: $hasChildren, children: ${children.length} items}';
  }
}
