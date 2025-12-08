import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_utils;
import 'package:win_explorer/core/utils/utils.dart';
import 'package:win_explorer/domain/entities/app_file.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';

/// 增强的目录类（组合模式）
/// 封装 Directory 并使用 AppFile 处理文件操作
class AppDirectory {
  /// 底层 Directory 对象
  final Directory _directory;

  AppDirectory._internal(this._directory, {String? name})
    : name = name ?? path_utils.basename(_directory.path);

  // ========== 工厂构造函数 ==========

  /// 从路径创建 AppDirectory
  factory AppDirectory({required String path, String? name}) {
    return AppDirectory._internal(Directory(path), name: name);
  }

  /// 从原生 Directory 对象创建
  factory AppDirectory.fromDirectory(Directory directory) {
    return AppDirectory._internal(directory);
  }

  /// 从 AppFileSystemEntity 创建（如果是目录）
  factory AppDirectory.fromFileSystemEntity(FileSystemEntity entity) {
    if (entity is Directory) {
      return AppDirectory._internal(entity);
    }
    throw ArgumentError('实体不是目录: ${entity.path}');
  }

  // ========== 基础属性 ==========

  /// 获取底层 Directory 对象
  Directory get directory => _directory;

  /// 获取目录路径
  String get path => _directory.path;

  /// 获取目录名称（路径的最后一部分）
  String name;

  /// 获取父目录路径
  String get parentPath => path_utils.dirname(path);

  /// 获取父目录的 AppDirectory 对象
  AppDirectory get parent => AppDirectory(path: parentPath);

  // ========== 状态检查 ==========

  /// 检查目录是否存在
  Future<bool> get exists async => await _directory.exists();

  /// 检查目录是否为空（不包含任何文件或子目录）
  Future<bool> get isEmpty async {
    try {
      final contents = await _directory.list().toList();
      return contents.isEmpty;
    } catch (e) {
      return true;
    }
  }

  /// 检查目录是否可读
  Future<bool> get isReadable async {
    try {
      await _directory.list().first;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 检查目录是否可写
  Future<bool> get isWritable async {
    try {
      final testFile = File('${_directory.path}/.write_test');
      await testFile.create();
      await testFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 检查目录是否隐藏（以点开头）
  Future<bool> get isHidden async {
    final baseName = path_utils.basename(_directory.path);
    return baseName.startsWith('.');
  }

  // ========== 目录信息 ==========

  /// 获取目录大小（递归计算所有文件的总大小）
  Future<int> get size async {
    try {
      int totalSize = 0;
      final files = await getAllAppFiles(recursive: true);
      for (final appFile in files) {
        totalSize += await appFile.size;
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 获取最后修改时间
  Future<DateTime?> get modifiedTime async {
    try {
      final stat = await _directory.stat();
      return stat.modified;
    } catch (e) {
      return null;
    }
  }

  /// 获取创建时间
  Future<DateTime?> get createdTime async {
    try {
      final stat = await _directory.stat();
      return stat.changed;
    } catch (e) {
      return null;
    }
  }

  /// 获取目录统计信息
  Future<DirectoryStats> get stats async {
    int fileCount = 0;
    int directoryCount = 0;
    int totalSize = 0;

    try {
      final entities = await _getAllEntitiesRecursive();
      for (final entity in entities) {
        if (entity is File) {
          fileCount++;
          try {
            final appFile = AppFile.fromFile(entity);
            totalSize += await appFile.size;
          } catch (e) {
            // 忽略无法统计的文件
          }
        } else if (entity is Directory) {
          directoryCount++;
        }
      }
    } catch (e) {
      // 部分目录可能无权限访问
    }

    return DirectoryStats(
      fileCount: fileCount,
      directoryCount: directoryCount,
      totalSize: totalSize,
    );
  }

  // ========== 目录内容操作 ==========

  /// 获取目录下的所有直接子项
  Future<List<FileSystemEntity>> listEntities({
    bool recursive = false,
    bool sortByType = true,
    bool foldersFirst = true,
  }) async {
    try {
      final entities = await _directory.list(recursive: recursive).toList();

      if (sortByType) {
        entities.sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;

          // 按类型排序
          if (aIsDir != bIsDir) {
            return foldersFirst ? (aIsDir ? -1 : 1) : (aIsDir ? 1 : -1);
          }

          // 同类型按名称排序（不区分大小写）
          final aName = path_utils.basename(a.path).toLowerCase();
          final bName = path_utils.basename(b.path).toLowerCase();
          return aName.compareTo(bName);
        });
      }

      return entities;
    } catch (e) {
      return [];
    }
  }

  Future<List<AppFileSystemEntity>> listAppEntities({
    bool recursive = false,
    bool sortByType = true,
    bool foldersFirst = true,
  }) async {
    try {
      final entities = await listEntities(
        recursive: recursive,
        sortByType: sortByType,
        foldersFirst: foldersFirst,
      );

      return entities
          .map((e) => AppFileSystemEntity.fromFileSystemEntity(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取目录下的所有文件（返回原生 File 对象）
  Future<List<File>> getAllFiles({bool recursive = true}) async {
    try {
      final files = <File>[];
      await for (final entity in _directory.list(recursive: recursive)) {
        if (entity is File) {
          files.add(entity);
        }
      }
      return files;
    } catch (e) {
      return [];
    }
  }

  /// 获取目录下的所有文件（返回 AppFile 对象）
  Future<List<AppFile>> getAllAppFiles({bool recursive = true}) async {
    try {
      final files = <AppFile>[];
      await for (final entity in _directory.list(recursive: recursive)) {
        if (entity is File) {
          files.add(AppFile.fromFile(entity));
        }
      }
      return files;
    } catch (e) {
      return [];
    }
  }

  /// 在目录中搜索文件（支持通配符，返回 AppFile 对象）
  Future<List<AppFile>> searchFiles(
    String pattern, {
    bool recursive = true,
  }) async {
    final results = <AppFile>[];
    final regExp = _patternToRegExp(pattern);

    try {
      final appFiles = await getAllAppFiles(recursive: recursive);
      for (final appFile in appFiles) {
        if (regExp.hasMatch(appFile.name)) {
          results.add(appFile);
        }
      }
    } catch (e) {
      // 处理权限错误等
    }

    return results;
  }

  /// 快速检查是否包含子目录
  Future<bool> hasSubdirectories({bool recursive = false}) async {
    try {
      await for (final entity in _directory.list(recursive: recursive)) {
        if (entity is Directory) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取子目录列表
  Future<List<AppDirectory>> getSubdirectories({bool recursive = false}) async {
    try {
      final directories = <AppDirectory>[];
      await for (final entity in _directory.list(recursive: recursive)) {
        if (entity is Directory) {
          // 只添加实际存在的目录
          final appDir = AppDirectory.fromDirectory(entity);
          if (await appDir.exists) {
            directories.add(appDir);
          }
        }
      }
      return directories;
    } catch (e) {
      return [];
    }
  }

  // ========== 目录操作 ==========

  /// 创建目录（如果不存在）
  Future<AppDirectory> createIfNotExists({bool recursive = true}) async {
    if (!await exists) {
      await _directory.create(recursive: recursive);
    }
    return this;
  }

  /// 安全删除目录（包含所有内容）
  Future<bool> deleteRecursively() async {
    try {
      await _directory.delete(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 复制目录到新位置
  Future<AppDirectory> copyTo(String newPath, {bool recursive = true}) async {
    final targetDir = AppDirectory(path: newPath);
    await targetDir.createIfNotExists(recursive: true);

    try {
      final entities = await _getAllEntitiesRecursive();
      for (final entity in entities) {
        final relativePath = path_utils.relative(entity.path, from: path);
        final targetPath = path_utils.join(newPath, relativePath);

        if (entity is File) {
          final appFile = AppFile.fromFile(entity);
          await appFile.copy(targetPath);
        } else if (entity is Directory) {
          await AppDirectory.fromDirectory(entity).createIfNotExists();
        }
      }
    } catch (e) {
      // 处理复制过程中的错误
    }

    return targetDir;
  }

  /// 重命名目录
  Future<AppDirectory> rename(String newPath) async {
    try {
      final newDir = await _directory.rename(newPath);
      return AppDirectory.fromDirectory(newDir);
    } catch (e) {
      throw Exception('重命名失败: $e');
    }
  }

  /// 在目录中创建子目录
  Future<AppDirectory> createSubdirectory(String name) async {
    final subdirPath = path_utils.join(path, name);
    final subdir = AppDirectory(path: subdirPath);
    await subdir.createIfNotExists();
    return subdir;
  }

  /// 在目录中创建文件（返回 AppFile 对象）
  Future<AppFile> createFile(String name, {String content = ''}) async {
    final filePath = path_utils.join(path, name);
    final appFile = AppFile(filePath);

    if (content.isNotEmpty) {
      await appFile.writeAsString(content);
    } else {
      // 如果 AppFile 有创建文件的方法，使用它
      await File(filePath).create();
    }

    return appFile;
  }

  /// 在目录中创建文件（返回原生 File 对象）
  Future<File> createRawFile(String name, {String content = ''}) async {
    final filePath = path_utils.join(path, name);
    final file = File(filePath);
    if (content.isNotEmpty) {
      await file.writeAsString(content);
    } else {
      await file.create();
    }
    return file;
  }

  // ========== 高级文件操作 ==========

  /// 读取目录下所有文本文件的内容
  Future<Map<String, String>> readAllTextFiles({bool recursive = true}) async {
    final contents = <String, String>{};
    try {
      final appFiles = await getAllAppFiles(recursive: recursive);
      for (final appFile in appFiles) {
        if (appFile.isText) {
          try {
            final content = await appFile.readAsString();
            contents[appFile.name] = content;
          } catch (e) {
            // 忽略无法读取的文件
            contents[appFile.name] = '[无法读取文件内容]';
          }
        }
      }
    } catch (e) {
      // 处理权限错误等
    }
    return contents;
  }

  /// 批量重命名文件
  Future<List<FileRenameResult>> batchRenameFiles(
    String pattern,
    String replacement, {
    bool recursive = false,
  }) async {
    final results = <FileRenameResult>[];
    try {
      final appFiles = await getAllAppFiles(recursive: recursive);
      final regExp = RegExp(pattern, caseSensitive: false);

      for (final appFile in appFiles) {
        if (regExp.hasMatch(appFile.name)) {
          final newName = appFile.name.replaceAll(regExp, replacement);
          try {
            final renamedFile = await appFile.rename(newName);
            results.add(
              FileRenameResult(
                originalPath: appFile.path,
                newPath: renamedFile.path,
                success: true,
              ),
            );
          } catch (e) {
            results.add(
              FileRenameResult(
                originalPath: appFile.path,
                newPath: appFile.path,
                success: false,
                error: e.toString(),
              ),
            );
          }
        }
      }
    } catch (e) {
      // 处理批量重命名过程中的错误
    }
    return results;
  }

  /// 查找重复文件（基于内容哈希）
  Future<Map<String, List<AppFile>>> findDuplicateFiles({
    bool recursive = true,
  }) async {
    final hashMap = <String, List<AppFile>>{};
    try {
      final appFiles = await getAllAppFiles(recursive: recursive);

      for (final appFile in appFiles) {
        try {
          final fileHash = await appFile.md5;
          if (!hashMap.containsKey(fileHash)) {
            hashMap[fileHash] = [];
          }
          hashMap[fileHash]!.add(appFile);
        } catch (e) {
          // 忽略无法计算哈希的文件
        }
      }

      // 只返回有重复的文件
      return Map.fromEntries(
        hashMap.entries.where((entry) => entry.value.length > 1),
      );
    } catch (e) {
      return {};
    }
  }

  /// 按文件类型分类文件
  Future<Map<String, List<AppFile>>> categorizeFilesByType({
    bool recursive = true,
  }) async {
    final categorized = <String, List<AppFile>>{};
    try {
      final appFiles = await getAllAppFiles(recursive: recursive);

      for (final appFile in appFiles) {
        final fileType = appFile.fileType;
        if (!categorized.containsKey(fileType)) {
          categorized[fileType] = [];
        }
        categorized[fileType]!.add(appFile);
      }
    } catch (e) {
      // 处理分类过程中的错误
    }
    return categorized;
  }

  // ========== 工具方法 ==========

  /// 获取人类可读的目录大小
  Future<String> getFormattedSize() async {
    final bytes = await size;
    return Utils.formatBytes(bytes);
  }

  /// 获取格式化的修改时间
  Future<String> getFormattedModifiedTime() async {
    final modified = await modifiedTime;
    if (modified == null) return '未知时间';

    final now = DateTime.now();
    final difference = now.difference(modified);

    if (difference.inDays == 0) {
      return '今天 ${_formatTime(modified)}';
    } else if (difference.inDays == 1) {
      return '昨天 ${_formatTime(modified)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${modified.year}-${_padZero(modified.month)}-${_padZero(modified.day)}';
    }
  }

  /// 检查目录是否包含指定文件
  Future<bool> containsFile(String fileName) async {
    try {
      final appFiles = await getAllAppFiles(recursive: true);
      return appFiles.any((appFile) => appFile.name == fileName);
    } catch (e) {
      return false;
    }
  }

  /// 获取目录树形结构
  Future<DirectoryTree> getTree({int maxDepth = 3}) async {
    return _buildTree(this, maxDepth: maxDepth, currentDepth: 0);
  }

  /// 获取目录信息摘要
  Future<DirectoryInfo> get info async {
    final stats = await this.stats;
    return DirectoryInfo(
      path: path,
      name: name,
      fileCount: stats.fileCount,
      directoryCount: stats.directoryCount,
      totalSize: stats.totalSize,
      formattedSize: stats.formattedSize,
      exists: await exists,
      isHidden: await isHidden,
      isWritable: await isWritable,
      modifiedTime: await modifiedTime,
      createdTime: await createdTime,
    );
  }

  // ========== 私有辅助方法 ==========

  /// 递归获取所有实体
  Future<List<FileSystemEntity>> _getAllEntitiesRecursive() async {
    final entities = <FileSystemEntity>[];
    try {
      await for (final entity in _directory.list(recursive: true)) {
        entities.add(entity);
      }
    } catch (e) {
      // 处理权限错误
    }
    return entities;
  }

  String _formatTime(DateTime time) {
    return '${_padZero(time.hour)}:${_padZero(time.minute)}';
  }

  String _padZero(int number) => number.toString().padLeft(2, '0');

  RegExp _patternToRegExp(String pattern) {
    final regexPattern = pattern
        .replaceAll('.', '\\.')
        .replaceAll('*', '.*')
        .replaceAll('?', '.');

    return RegExp(regexPattern, caseSensitive: false);
  }

  Future<DirectoryTree> _buildTree(
    AppDirectory dir, {
    int maxDepth = 3,
    int currentDepth = 0,
  }) async {
    final children = <DirectoryTree>[];

    if (currentDepth < maxDepth) {
      try {
        final subDirs = await dir.getSubdirectories(recursive: false);
        for (final subDir in subDirs) {
          final subTree = await _buildTree(
            subDir,
            maxDepth: maxDepth,
            currentDepth: currentDepth + 1,
          );
          children.add(subTree);
        }
      } catch (e) {
        // 忽略无权限访问的目录
      }
    }

    return DirectoryTree(
      directory: dir,
      children: children,
      depth: currentDepth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppDirectory &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() {
    return 'AppDirectory{path: $path, name: $name}';
  }
}

// ========== 辅助数据类 ==========

/// 目录统计信息
class DirectoryStats {
  final int fileCount;
  final int directoryCount;
  final int totalSize;

  const DirectoryStats({
    required this.fileCount,
    required this.directoryCount,
    required this.totalSize,
  });

  /// 获取人类可读的总大小
  String get formattedSize {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (totalSize == 0) return '0 B';

    int unitIndex = 0;
    double size = totalSize.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(unitIndex > 0 ? 1 : 0)} ${units[unitIndex]}';
  }

  @override
  String toString() =>
      'Files: $fileCount, Directories: $directoryCount, Size: $formattedSize';
}

/// 目录树结构
class DirectoryTree {
  final AppDirectory directory;
  final List<DirectoryTree> children;
  final int depth;

  const DirectoryTree({
    required this.directory,
    required this.children,
    required this.depth,
  });

  /// 打印树形结构
  void printTree({String indent = ''}) {
    print('$indent${directory.name}/');
    for (int i = 0; i < children.length; i++) {
      final isLast = i == children.length - 1;
      final newIndent = '$indent${isLast ? '  ' : '│ '}';
      children[i].printTree(indent: newIndent);
    }
  }
}

/// 文件重命名结果
class FileRenameResult {
  final String originalPath;
  final String newPath;
  final bool success;
  final String? error;

  const FileRenameResult({
    required this.originalPath,
    required this.newPath,
    required this.success,
    this.error,
  });
}

/// 目录信息摘要
class DirectoryInfo {
  final String path;
  final String name;
  final int fileCount;
  final int directoryCount;
  final int totalSize;
  final String formattedSize;
  final bool exists;
  final bool isHidden;
  final bool isWritable;
  final DateTime? modifiedTime;
  final DateTime? createdTime;

  const DirectoryInfo({
    required this.path,
    required this.name,
    required this.fileCount,
    required this.directoryCount,
    required this.totalSize,
    required this.formattedSize,
    required this.exists,
    required this.isHidden,
    required this.isWritable,
    required this.modifiedTime,
    required this.createdTime,
  });

  @override
  String toString() =>
      'DirectoryInfo{name: $name, files: $fileCount, size: $formattedSize}';
}

/// 扩展方法，为原生 Directory 添加便捷转换
extension DirectoryExtensions on Directory {
  AppDirectory get asAppDirectory => AppDirectory.fromDirectory(this);
}
