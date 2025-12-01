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
  bool _hasChildren = false;
  
  // 提供 getter 方法确保每次获取最新状态
  bool get hasChildren => _hasChildren;

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
    _updateHasChildren();
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

  /// 动态检查是否有子目录
  Future<void> _updateHasChildren() async {
    try {
      // 检查是否存在子目录（而不是所有文件）
      final subDirs = await appDirectory.getSubdirectories(recursive: false);
      _hasChildren = subDirs.isNotEmpty;
    } catch (e) {
      _hasChildren = false;
    }
  }

  /// 获取子节点
  Future<void> getChildren() async {
    try {
      List<AppDirectory> subdirs = await appDirectory.getSubdirectories(recursive: false);
      children = subdirs
          .map((subdir) => SidebarTreeNode(appDirectory: subdir))
          .toList();
      // 更新 hasChildren 状态
      _hasChildren = children != null && children!.isNotEmpty;
    } catch (e) {
      children = [];
      _hasChildren = false;
    }
  }

  /// 切换展开状态时重新检查子节点
  Future<void> toggleExpanded() async {
    isExpanded = !isExpanded;
    if (isExpanded && (children == null || children!.isEmpty)) {
      await getChildren();
    } else if (isExpanded) {
      // 即使已有 children，也重新检查以确保准确性
      await _updateHasChildren();
    }
  }

  @override
  String toString() {
    return 'SidebarTreeNode{appDirectory: $appDirectory, name: $name, isExpanded: $isExpanded, isHovered: $isHovered, children: $children}';
  }
}