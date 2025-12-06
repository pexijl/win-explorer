import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:win_explorer/domain/entities/app_directory.dart';

/// 树形结构节点
class SidebarTreeNode with ChangeNotifier {
  final AppDirectory data;
  final int level;
  bool isExpanded;

  List<SidebarTreeNode>? children;

  bool _hasChildren = false;

  bool get hasChildren => _hasChildren;

  set hasChildren(bool value) {
    if (_hasChildren != value) {
      _hasChildren = value;
      notifyListeners();
    }
  }

  SidebarTreeNode({
    required this.data,
    required this.level,
    this.isExpanded = false,
    bool hasChildren = false,
    this.children,
  }) {
    _hasChildren = hasChildren;
  }

  /// 异步创建 SidebarTreeNode，检查是否有子节点
  static Future<SidebarTreeNode> create({
    required AppDirectory data,
    required int level,
    bool isExpanded = false,
    List<SidebarTreeNode>? children,
  }) async {
    var node = SidebarTreeNode(
      data: data,
      level: level,
      isExpanded: isExpanded,
      children: children,
    );
    bool has = await data.hasSubdirectories();
    node.hasChildren = has;
    return node;
  }


  @override
  String toString() {
    return 'SidebarTreeNode{data: $data, level: $level, isExpanded: $isExpanded, hasChildren: $hasChildren, children: ${children?.length ?? 0} items}';
  }
}
