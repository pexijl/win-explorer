import 'dart:ui';

class SidebarTreeNode {
  /// 节点名称
  final String name;

  /// 节点路径
  final String path;

  /// 是否展开
  bool isExpanded;

  /// 是否选中
  bool _isSelected = false;

  /// 是否悬停
  bool isHovered;

  /// 子节点
  final List<SidebarTreeNode>? children;

  // onTap 回调函数
  final VoidCallback? onTap;

  SidebarTreeNode({
    required this.name,
    required this.path,
    this.isExpanded = false,
    this.isHovered = false,
    this.children,
    this.onTap,
  });

  bool get hasChildren => children != null && children!.isNotEmpty;

  bool get isSelected => _isSelected;

  void select() {
    _isSelected = true;
  }

  void unselect() {
    _isSelected = false;
  }
}
