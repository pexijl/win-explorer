import 'dart:async';

/// 文件系统变更类型
enum FileSystemChangeType {
  /// 某个目录的“子目录列表”发生变化（新增/删除/重命名等）
  directoryChildrenChanged,
}

/// 文件系统变更事件
class FileSystemChange {
  final FileSystemChangeType type;
  final String directoryPath;

  const FileSystemChange({required this.type, required this.directoryPath});
}

/// 文件系统事件广播服务（轻量级 EventBus）
///
/// 目前用于：新建文件夹后通知侧边栏刷新树节点。
class FileSystemService {
  FileSystemService._();

  static final FileSystemService instance = FileSystemService._();

  final StreamController<FileSystemChange> _controller =
      StreamController<FileSystemChange>.broadcast();

  Stream<FileSystemChange> get changes => _controller.stream;

  void notifyDirectoryChildrenChanged(String directoryPath) {
    // “此电脑”是装饰性的虚拟节点，不是实际目录，更新时应排除。
    if (directoryPath == '此电脑') return;
    if (_controller.isClosed) return;
    _controller.add(
      FileSystemChange(
        type: FileSystemChangeType.directoryChildrenChanged,
        directoryPath: directoryPath,
      ),
    );
  }
}
