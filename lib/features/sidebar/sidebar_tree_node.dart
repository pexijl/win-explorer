import 'package:flutter/foundation.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';

/// 树形结构节点, 继承自 ChangeNotifier 以支持状态管理
class SidebarTreeNode {
  /// 节点的id
  final String id = UniqueKey().toString();

  /// 节点标签
  final String label;

  /// 节点的数据实体
  final AppDirectory appDirectory;

  /// 子节点
  List<SidebarTreeNode>? children;

  /// 是否有子节点
  bool _hasChildren = false;
  bool get hasChildren => _hasChildren;

  /// 是否展开
  bool isExpanded;

  /// 是否是占位符 (例如 Loading...)，跳过实际的 I/O 检查和加载
  final bool isPlaceholder;

  SidebarTreeNode({
    required this.label,
    required this.appDirectory,
    List<SidebarTreeNode>? children,
    this.isExpanded = false,
    this.isPlaceholder = false,
  }) {
    if (!isPlaceholder) {
      _checkForChildren();
    }
  }

  /// 检查是否有子目录
  Future<void> _checkForChildren() async {
    try {
      final subDirs = await appDirectory.getSubdirectories(recursive: false);
      _hasChildren = subDirs.isNotEmpty;
    } catch (e) {
      _hasChildren = false;
    }
  }

  /// 加载子节点
  Future<void> loadChildren() async {
    if (isPlaceholder) return;
    if (children != null) return;
    try {
      List<AppDirectory> subdirs = await appDirectory.getSubdirectories(
        recursive: false,
      );
      children = subdirs
          .map(
            (subdir) =>
                SidebarTreeNode(label: subdir.name, appDirectory: subdir),
          )
          .toList();
      _hasChildren = children!.isNotEmpty;
    } catch (e) {
      children = [];
      _hasChildren = false;
    }
  }

  /// 切换展开状态
  Future<void> toggleExpanded() async {
    print('toggleExpanded');
    if (isPlaceholder) return;
    isExpanded = !isExpanded;
    if (isExpanded) {
      await loadChildren();
    }
  }

  @override
  String toString() {
    return 'SidebarTreeNode{id: $id, label: $label, appDirectory: $appDirectory, children: $children}';
  }
}
