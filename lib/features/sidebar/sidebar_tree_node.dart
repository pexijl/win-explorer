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
  final List<SidebarTreeNode>? children;

  // onTap 回调函数
  final VoidCallback? onTap;

  SidebarTreeNode({
    required this.appDirectory,
    this.isExpanded = false,
    this.isHovered = false,
    this.children,
    this.onTap,
    String? name,
  }) : name = name ?? appDirectory.name;

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

  bool get hasChildren => children != null && children!.isNotEmpty;
}
