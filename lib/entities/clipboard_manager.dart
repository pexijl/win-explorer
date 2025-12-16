import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:win_explorer/entities/app_directory.dart';
import 'package:win_explorer/entities/app_file_system_entity.dart';

class ClipboardItem {
  final AppFileSystemEntity entity;
  final bool isCut;

  ClipboardItem(this.entity, this.isCut);
}

class ClipboardManager {
  static final ClipboardManager _instance = ClipboardManager._internal();
  factory ClipboardManager() => _instance;
  ClipboardManager._internal();

  List<ClipboardItem> _items = [];

  bool get hasItems => _items.isNotEmpty;
  bool get isCutMode => _items.isNotEmpty && _items.first.isCut;

  void copy(AppFileSystemEntity entity) {
    _items = [ClipboardItem(entity, false)];
  }

  void cut(AppFileSystemEntity entity) {
    _items = [ClipboardItem(entity, true)];
  }

  void clear() {
    _items.clear();
  }

  /// 生成唯一的名称，如果目标路径已存在
  String _generateUniqueName(String targetDir, String name) {
    final ext = path.extension(name);
    final nameWithoutExt = path.basenameWithoutExtension(name);
    String newName = name;
    int counter = 1;
    while (File(path.join(targetDir, newName)).existsSync() ||
        Directory(path.join(targetDir, newName)).existsSync()) {
      newName = '$nameWithoutExt ($counter)$ext';
      counter++;
    }
    return newName;
  }

  Future<void> pasteTo(AppDirectory targetDirectory) async {
    if (_items.isEmpty) return;

    for (final item in _items) {
      final baseName = item.entity.name;
      final uniqueName = _generateUniqueName(targetDirectory.path, baseName);
      final newPath = path.join(targetDirectory.path, uniqueName);

      if (item.isCut) {
        await item.entity.moveTo(newPath);
      } else {
        await item.entity.copyTo(newPath);
      }
    }

    // 剪切模式下清空剪贴板
    if (isCutMode) {
      clear();
    }
  }
}
