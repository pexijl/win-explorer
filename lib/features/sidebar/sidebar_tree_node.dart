import 'dart:async';

import 'package:win_explorer/domain/entities/app_directory.dart';

/// 树形结构节点
class SidebarTreeNode {
  final AppDirectory data;
  final int level;
  bool isExpanded;

  List<SidebarTreeNode>? children;

  bool hasChildren;

  SidebarTreeNode({
    required this.data,
    required this.level,
    this.isExpanded = false,
    this.children,
    this.hasChildren = false,
  });

  /// 异步创建 SidebarTreeNode，检查是否有子节点
  static Future<SidebarTreeNode> create({
    required AppDirectory data,
    required int level,
    bool isExpanded = false,
    List<SidebarTreeNode>? children,
  }) async {
    bool hasChildren = await data.hasSubdirectories();
    return SidebarTreeNode(
      data: data,
      level: level,
      isExpanded: isExpanded,
      children: children,
      hasChildren: hasChildren,
    );
  }


  @override
  String toString() {
    return 'SidebarTreeNode{data: $data, level: $level, isExpanded: $isExpanded, hasChildren: $hasChildren, children: ${children?.length ?? 0} items}';
  }
}
