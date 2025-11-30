import 'dart:io' as io;
import 'package:path/path.dart' as path_utils;

import 'file_system_entity .dart';

/// 目录实体类
///
/// 用于封装目录路径，并提供列举内容、计算大小等操作。
class Directory {
  /// 目录的完整路径。
  final String path;

  /// 创建一个 Directory 实例。
  ///
  /// [path]: 目录的绝对路径或相对路径（相对于当前工作目录可能不安全，建议使用绝对路径）。
  Directory(this.path);

  /// 获取此目录的 [dart:io.Directory] 对象。
  /// 用于与底层文件系统交互。
  io.Directory get _ioDirectory => io.Directory(path);

  /// 判断该目录在磁盘上是否存在。
  Future<bool> exists() async => await _ioDirectory.exists();

  /// 获取此目录的绝对路径。
  String get absolutePath => _ioDirectory.absolute.path;

  /// 获取目录的名称（路径的最后一部分）。
  String get name => path_utils.basename(_ioDirectory.absolute.path);

  /// 获取父目录的 Directory 对象。
  /// 如果已经是根目录，则返回 null。
  Directory? get parentDirectory {
    final parentPath = _ioDirectory.parent.path;
    // 防止在根目录（如 'C:\'）时 parent 仍返回自身
    if (parentPath == path) {
      return null;
    }
    return Directory(parentPath);
  }

  /// 列出目录中的所有文件和子目录。
  ///
  /// [loadMetadata]: 是否加载文件的元数据（如修改时间等），默认为 false。
  Future<List<FileSystemEntity>> listEntities({
    bool loadMetadata = false,
  }) async {
    try {
      if (!await exists()) {
        return [];
      }

      final List<io.FileSystemEntity> entities = await _ioDirectory
          .list()
          .toList();

      final List<FileSystemEntity> results = [];

      for (final entity in entities) {
        final stat = await entity.stat(); // 获取元数据

        results.add(
          FileSystemEntity(
            name: path_utils.basename(entity.path),
            path: entity.path,
            size: await _getEntitySize(stat, entity), // 计算大小
            isDirectory: stat.type == io.FileSystemEntityType.directory,
            modifiedTime: stat.modified,
          ),
        );
      }

      // 可选：排序，例如文件夹在前，然后按名称排序
      results.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return results;
    } catch (e) {
      print('Error listing directory $path: $e');
      return []; // 发生错误时返回空列表
    }
  }

  /// 辅助方法：计算文件系统实体的大小
  Future<int> _getEntitySize(
    io.FileStat stat,
    io.FileSystemEntity entity,
  ) async {
    if (stat.type == io.FileSystemEntityType.directory) {
      // 对于目录，可以递归计算其下所有内容的总大小
      // 注意：对于包含大量文件的目录，此操作可能较慢，需谨慎使用
      try {
        final dir = io.Directory(entity.path);
        int totalSize = 0;
        final fileStream = dir
            .list(recursive: true)
            .where((e) => e is io.File)
            .cast<io.File>();
        await for (final file in fileStream) {
          try {
            totalSize += (await file.stat()).size;
          } catch (e) {
            // 忽略无权限访问的文件
          }
        }
        return totalSize;
      } catch (e) {
        return 0; // 计算目录大小时出错则返回0
      }
    } else if (stat.type == io.FileSystemEntityType.file) {
      return stat.size; // 文件直接返回大小
    }
    return 0; // 链接等其他类型返回0
  }
}
