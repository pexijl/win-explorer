import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';

/// 树形结构节点, 继承自 ChangeNotifier 以支持状态管理
class SidebarTreeNode extends ChangeNotifier {
  SidebarTreeNode({
    required this.label,
    required this.appDirectory,
    List<SidebarTreeNode>? children,
    this.isExpanded = false,
    this.isPlaceholder = false,
    this.depth = 0,
    String? id,
  }) : id = id ?? appDirectory.path {
    if (children != null) {
      this.children = children;
      _updateHasChildren(children.isNotEmpty, notify: false);
    }

    if (!isPlaceholder) {
      _childrenProbe = _checkForChildren();
    }
  }

  /// 节点的id (默认使用目录路径, 便于稳定选中)
  final String id;

  /// 节点标签
  final String label;

  /// 节点的数据实体
  final AppDirectory appDirectory;

  /// 节点深度 (用于缩进)
  final int depth;

  /// 子节点引用 (用于备选树组件)
  List<SidebarTreeNode>? children;

  /// 是否展开
  bool isExpanded;

  /// 是否是占位符 (例如 Loading...)，跳过实际的 I/O 检查和加载
  final bool isPlaceholder;

  bool _hasChildren = false;
  bool _hasResolvedChildren = false;
  bool _isLoadingChildren = false;

  Future<void>? _childrenProbe;
  Future<void>? _loadingFuture;

  bool get hasChildren => _hasChildren;
  bool get hasResolvedChildren => _hasResolvedChildren;
  bool get isLoadingChildren => _isLoadingChildren;
  bool get showExpander => _isLoadingChildren || !_hasResolvedChildren || _hasChildren;

  /// 检查是否有子目录
  Future<void> _checkForChildren() {
    _childrenProbe ??= () async {
      try {
        final hasDirs = await appDirectory.hasSubdirectories(recursive: false);
        _updateHasChildren(hasDirs);
      } catch (_) {
        _updateHasChildren(false);
      }
    }();
    return _childrenProbe!;
  }

  void _updateHasChildren(bool value, {bool notify = true}) {
    final changed = !_hasResolvedChildren || _hasChildren != value;
    _hasChildren = value;
    _hasResolvedChildren = true;
    if (changed && notify) {
      notifyListeners();
    }
  }

  void markHasChildren(bool value) => _updateHasChildren(value);

  void markChildrenUnknown() {
    if (!_hasResolvedChildren) return;
    _hasResolvedChildren = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoadingChildren == value) return;
    _isLoadingChildren = value;
    notifyListeners();
  }

  void markLoading(bool value) => _setLoading(value);

  /// 加载子节点 (仅在节点自身需要时使用)
  Future<void> loadChildren() {
    if (isPlaceholder) return Future.value();
    _loadingFuture ??= _doLoadChildren();
    return _loadingFuture!;
  }

  Future<void> _doLoadChildren() async {
    _setLoading(true);
    try {
      final subdirs = await appDirectory.getSubdirectories(recursive: false);
      children = subdirs
          .map(
            (subdir) => SidebarTreeNode(
              label: subdir.name,
              appDirectory: subdir,
              depth: depth + 1,
            ),
          )
          .toList();
      _updateHasChildren(children!.isNotEmpty);
    } catch (_) {
      children = [];
      _updateHasChildren(false);
    } finally {
      _setLoading(false);
      _loadingFuture = null;
    }
  }

  /// 切换展开状态
  Future<void> toggleExpanded() async {
    if (isPlaceholder) return;
    isExpanded = !isExpanded;
    notifyListeners();
    if (isExpanded) {
      await loadChildren();
    }
  }

  void markExpanded(bool expanded) {
    if (isExpanded == expanded) return;
    isExpanded = expanded;
    notifyListeners();
  }

  @override
  String toString() {
    return 'SidebarTreeNode{id: $id, label: $label, depth: $depth, appDirectory: $appDirectory, children: $children}';
  }
}
