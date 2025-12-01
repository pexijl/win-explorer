import 'dart:ui';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/drive.dart';

class SidebarTreeNode {
  /// 节点的数据实体
  AppDirectory appDirectory;

  /// 节点名称
  String? name;

  /// 是否展开
  bool isExpanded;

  /// 是否悬停
  bool isHovered;

  /// 子节点
  List<SidebarTreeNode>? children;

  /// 是否有子节点
  bool hasChildren = false;

  // onTap 回调函数
  final VoidCallback? onTap;

  SidebarTreeNode({
    required this.appDirectory,
    this.isExpanded = false,
    this.isHovered = false,
    this.children,
    this.onTap,
    String? name,
  }) : name = name ?? appDirectory.name {
    getHasChildren();
  }

  SidebarTreeNode.fromDrive({
    required Drive drive,
    bool isExpanded = false,
    bool isHovered = false,
    List<SidebarTreeNode>? children,
    VoidCallback? onTap,
  }) : this(
         appDirectory: AppDirectory(drive.mountPoint),
         isExpanded: isExpanded,
         isHovered: isHovered,
         children: children,
         onTap: onTap,
         name: drive.name,
       );

  /// 获取子节点
  Future<void> getChildren() async {
    List<AppDirectory> subdirs = await appDirectory.getSubdirectories();
    children = subdirs
        .map((subdir) => SidebarTreeNode(appDirectory: subdir))
        .toList();
  }

  Future<void> getHasChildren() async {
    if (children != null && children!.isNotEmpty) {
      hasChildren = true;
      return;
    }
    hasChildren = !(await appDirectory.isEmpty);
  }

  @override
  String toString() {
    return 'SidebarTreeNode{appDirectory: $appDirectory, name: $name, isExpanded: $isExpanded, isHovered: $isHovered, children: $children, onTap: $onTap}';
  }
}
