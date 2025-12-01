class SidebarTreeNode {
  /// 节点名称
  final String name;

  /// 节点路径
  final String path;

  /// 是否展开
  bool isExpanded;

  /// 是否选中
  bool isSelected;

  /// 是否悬停
  bool isHovered;

  /// 子节点
  final List<SidebarTreeNode>? children;

  SidebarTreeNode({
    required this.name,
    required this.path,
    this.isExpanded = false,
    this.isSelected = false,
    this.isHovered = false,
    this.children,
  });

  bool get hasChildren => children != null && children!.isNotEmpty;


  void onTap() {
    isSelected = true;
  }
}
