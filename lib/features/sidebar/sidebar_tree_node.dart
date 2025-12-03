import 'package:flutter/foundation.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/drive.dart';

class SidebarTreeNode extends ChangeNotifier {
  /// 节点的数据实体
  final AppDirectory appDirectory;

  /// 节点名称
  final String name;

  /// 是否展开
  bool _isExpanded;
  bool get isExpanded => _isExpanded;

  /// 子节点
  List<SidebarTreeNode>? _children;
  List<SidebarTreeNode>? get children => _children;

  /// 是否有子节点
  bool _hasChildren = false;
  bool get hasChildren => _hasChildren;

  /// 是否正在加载
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SidebarTreeNode({
    String? name,
    required this.appDirectory,
    bool isExpanded = false,
    List<SidebarTreeNode>? children,
  }) : _isExpanded = isExpanded,
       _children = children,
       name = name ?? appDirectory.name {
    _checkForChildren();
  }

  SidebarTreeNode.fromDrive({
    required Drive drive,
    bool isExpanded = false,
    List<SidebarTreeNode>? children,
  }) : this(
         appDirectory: AppDirectory(drive.mountPoint),
         isExpanded: isExpanded,
         children: children,
         name: drive.name,
       );

  /// 检查是否有子目录
  Future<void> _checkForChildren() async {
    try {
      final subDirs = await appDirectory.getSubdirectories(recursive: false);
      _hasChildren = subDirs.isNotEmpty;
      notifyListeners();
    } catch (e) {
      _hasChildren = false;
      notifyListeners();
    }
  }

  /// 加载子节点
  Future<void> loadChildren() async {
    if (_children != null) return;

    _isLoading = true;
    notifyListeners();

    try {
      List<AppDirectory> subdirs = await appDirectory.getSubdirectories(recursive: false);
      _children = subdirs
          .map((subdir) => SidebarTreeNode(appDirectory: subdir))
          .toList();
      _hasChildren = _children!.isNotEmpty;
    } catch (e) {
      _children = [];
      _hasChildren = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 切换展开状态
  Future<void> toggleExpanded() async {
    _isExpanded = !_isExpanded;
    notifyListeners();
    
    if (_isExpanded) {
      await loadChildren();
    }
  }

  @override
  String toString() {
    return 'SidebarTreeNode{name: $name, isExpanded: $_isExpanded, childrenCount: ${_children?.length}}';
  }
}