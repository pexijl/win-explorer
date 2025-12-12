import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_utils;
import 'package:win_explorer/core/utils/utils.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/app_file.dart';

const List<String> imageExtensions = [
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.bmp',
  '.webp',
];

// ========== 自定义异常类 ==========

/// 文件系统实体异常基类
abstract class FileSystemEntityException implements Exception {
  final String message;
  final String? path;

  FileSystemEntityException(this.message, [this.path]);

  @override
  String toString() => path != null ? '$message: $path' : message;
}

/// 不支持的实体类型异常
class UnsupportedEntityTypeException extends FileSystemEntityException {
  UnsupportedEntityTypeException(String type, [String? path])
    : super('不支持的实体类型: $type', path);
}

/// 实体不存在异常
class EntityNotFoundException extends FileSystemEntityException {
  EntityNotFoundException([String? path]) : super('实体不存在', path);
}

/// 权限被拒绝异常
class PermissionDeniedException extends FileSystemEntityException {
  PermissionDeniedException(String operation, [String? path])
    : super('权限被拒绝: $operation', path);
}

/// 无效操作异常
class InvalidOperationException extends FileSystemEntityException {
  InvalidOperationException(String operation, String reason, [String? path])
    : super('无效操作 $operation: $reason', path);
}

/// 应用文件系统实体类（组合模式）
class AppFileSystemEntity {
  final FileSystemEntity _fileSystemEntity; // 底层实体
  late final dynamic _typedEntity; // 可以是 AppFile 或 AppDirectory

  // ========== 缓存字段 ==========
  int? _cachedSize;
  DateTime? _cachedModifiedTime;
  DateTime? _cachedCreatedTime;
  bool? _cachedIsHidden;
  bool? _cachedIsReadable;
  bool? _cachedIsWritable;
  FileSystemEntityType? _cachedType;

  AppFileSystemEntity._internal(this._fileSystemEntity) {
    // 根据类型初始化对应的实体
    if (_fileSystemEntity is File) {
      _typedEntity = AppFile.fromFile(_fileSystemEntity);
    } else if (_fileSystemEntity is Directory) {
      _typedEntity = AppDirectory.fromDirectory(_fileSystemEntity);
    } else {
      throw UnsupportedEntityTypeException(
        _fileSystemEntity.runtimeType.toString(),
        _fileSystemEntity.path,
      );
    }
  }

  // ========== 工厂构造函数 ==========

  /// 从路径创建实体（异步，自动检测类型）
  static Future<AppFileSystemEntity> fromPath(String path) async {
    final type = await FileSystemEntity.type(path);
    if (type == FileSystemEntityType.file) {
      return AppFileSystemEntity.fromFile(File(path));
    } else if (type == FileSystemEntityType.directory) {
      return AppFileSystemEntity.fromDirectory(Directory(path));
    } else {
      throw UnsupportedError('不支持的实体类型: $type');
    }
  }

  /// 从 File 创建（同步）
  factory AppFileSystemEntity.fromFile(File file) {
    return AppFileSystemEntity._internal(file);
  }

  /// 从 Directory 创建（同步）
  factory AppFileSystemEntity.fromDirectory(Directory directory) {
    return AppFileSystemEntity._internal(directory);
  }

  /// 从 AppFile 创建
  factory AppFileSystemEntity.fromAppFile(AppFile appFile) {
    return AppFileSystemEntity._internal(appFile.file);
  }

  /// 从 AppDirectory 创建
  factory AppFileSystemEntity.fromAppDirectory(AppDirectory appDirectory) {
    return AppFileSystemEntity._internal(appDirectory.directory);
  }

  // 从 FileSystemEntity 创建
  factory AppFileSystemEntity.fromFileSystemEntity(FileSystemEntity entity) {
    return AppFileSystemEntity._internal(entity);
  }

  // ========== 类型检查和转换 ==========

  /// 获取实体类型
  Future<FileSystemEntityType> get type async {
    if (_cachedType != null) return _cachedType!;
    _cachedType = await FileSystemEntity.type(path);
    return _cachedType!;
  }

  /// 检查是否是文件
  bool get isFile => _fileSystemEntity is File;

  /// 检查是否是目录
  bool get isDirectory => _fileSystemEntity is Directory;

  /// 检查是否是快捷方式
  bool get isLink => _fileSystemEntity is Link;

  /// 检查是否为图片
  bool get isImage {
    return isFile && imageExtensions.contains(extension);
  }

  /// 转换为 AppFile（如果是文件）
  AppFile? get asAppFile => _typedEntity is AppFile ? _typedEntity : null;

  /// 转换为 AppDirectory（如果是目录）
  AppDirectory? get asAppDirectory =>
      _typedEntity is AppDirectory ? _typedEntity : null;

  /// 安全转换为 AppFile
  Future<AppFile> toAppFile() async {
    if (isFile) {
      return _typedEntity as AppFile;
    }
    throw StateError('实体不是文件: $path');
  }

  /// 安全转换为 AppDirectory
  Future<AppDirectory> toAppDirectory() async {
    if (isDirectory) {
      return _typedEntity as AppDirectory;
    }
    throw StateError('实体不是目录: $path');
  }

  // ========== 基础属性 ==========

  /// 获取底层实体
  FileSystemEntity get entity => _fileSystemEntity;

  /// 获取实体路径
  String get path => _fileSystemEntity.path;

  /// 获取实体名称
  String get name => path_utils.basename(path);

  /// 获取父目录路径
  String get parentPath => path_utils.dirname(path);

  /// 获取文件扩展名
  String get extension => path_utils.extension(path).toLowerCase();

  // ========== 状态检查（委托给具体实现） ==========

  /// 检查实体是否存在
  Future<bool> get exists async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity).exists;
    } else {
      return await (_typedEntity as AppDirectory).exists;
    }
  }

  /// 检查是否为空
  Future<bool> get isEmpty async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity).isEmpty;
    } else {
      return await (_typedEntity as AppDirectory).isEmpty;
    }
  }

  /// 检查是否可读
  Future<bool> get isReadable async {
    if (_cachedIsReadable != null) return _cachedIsReadable!;
    if (_typedEntity is AppFile) {
      _cachedIsReadable = await (_typedEntity).isReadable;
    } else {
      _cachedIsReadable = await (_typedEntity as AppDirectory).isReadable;
    }
    return _cachedIsReadable!;
  }

  /// 检查是否可写
  Future<bool> get isWritable async {
    if (_cachedIsWritable != null) return _cachedIsWritable!;
    if (_typedEntity is AppFile) {
      _cachedIsWritable = await (_typedEntity).isWritable;
    } else {
      _cachedIsWritable = await (_typedEntity as AppDirectory).isWritable;
    }
    return _cachedIsWritable!;
  }

  /// 检查是否隐藏
  Future<bool> get isHidden async {
    if (_cachedIsHidden != null) return _cachedIsHidden!;
    if (_typedEntity is AppFile) {
      _cachedIsHidden = await (_typedEntity).isHidden;
    } else {
      _cachedIsHidden = await (_typedEntity as AppDirectory).isHidden;
    }
    return _cachedIsHidden!;
  }

  // ========== 文件信息（委托给具体实现） ==========

  /// 获取实体大小
  Future<int> get fileSize async {
    if (_cachedSize != null) return _cachedSize!;
    final stat = await _fileSystemEntity.stat();
    _cachedSize = stat.size;
    return _cachedSize!;
  }

  /// 获取实体大小（包含子项，目录专用）
  Future<int> get directorySize async {
    if (_cachedSize != null) return _cachedSize!;
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      _cachedSize = await directory.size;
      return _cachedSize!;
    } else {
      throw StateError('实体不是目录: $path');
    }
  }

  /// 获取最后修改时间
  Future<DateTime?> get modifiedTime async {
    if (_cachedModifiedTime != null) return _cachedModifiedTime;
    final stat = await _fileSystemEntity.stat();
    _cachedModifiedTime = stat.modified;
    return _cachedModifiedTime;
  }

  /// 获取创建时间
  Future<DateTime?> get createdTime async {
    if (_cachedCreatedTime != null) return _cachedCreatedTime;
    final stat = await _fileSystemEntity.stat();
    _cachedCreatedTime = stat.changed;
    return _cachedCreatedTime;
  }

  /// 获取显示用的图标类型
  IconData get icon {
    if (isDirectory) {
      return Icons.folder;
    } else if (isImage) {
      return Icons.image;
    } else {
      return Icons.insert_drive_file;
    }
  }

  /// 获取显示用的图标颜色
  MaterialColor get iconColor {
    if (isDirectory) {
      return Colors.amber;
    } else {
      return Colors.grey;
    }
  }

  String get typeName {
    if (isDirectory) {
      return '文件夹';
    }
    if (extension.isEmpty) {
      return '文件';
    }
    return '${extension.substring(1).toUpperCase()}文件';
  }

  // ========== 目录操作（仅目录有效） ==========

  /// 获取目录的子项
  Future<List<AppFileSystemEntity>> getChildren() async {
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      final entities = await directory.listEntities();

      final children = <AppFileSystemEntity>[];
      for (final entity in entities) {
        children.add(AppFileSystemEntity._internal(entity));
      }

      return children;
    }
    throw StateError('只有目录才能获取子项: $path');
  }

  /// 获取目录下的所有文件
  Future<List<AppFileSystemEntity>> getAllFiles({bool recursive = true}) async {
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      final files = await directory.getAllFiles(recursive: recursive);

      return files.map((file) => AppFileSystemEntity.fromFile(file)).toList();
    }
    return [this]; // 如果是文件，返回自身
  }

  /// 搜索文件
  Future<List<AppFileSystemEntity>> searchFiles(
    String pattern, {
    bool recursive = true,
  }) async {
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      final files = await directory.searchFiles(pattern, recursive: recursive);

      return files
          .map((file) => AppFileSystemEntity.fromFile(file as File))
          .toList();
    }
    return [];
  }

  /// 获取子目录列表
  Future<List<AppFileSystemEntity>> getSubdirectories({
    bool recursive = false,
  }) async {
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      final subDirs = await directory.getSubdirectories(recursive: recursive);

      return subDirs
          .map((dir) => AppFileSystemEntity.fromDirectory(dir.directory))
          .toList();
    }
    return [];
  }

  // ========== 文件操作（仅文件有效） ==========

  /// 读取文件内容
  Future<String> readAsString({Encoding encoding = utf8}) async {
    if (isFile) {
      final file = _typedEntity as AppFile;
      return await file.readAsString(encoding: encoding);
    }
    throw StateError('只有文件才能读取内容: $path');
  }

  /// 写入文件内容
  Future<void> writeAsString(
    String content, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    if (isFile) {
      final file = _typedEntity as AppFile;
      return await file.writeAsString(
        content,
        mode: mode,
        encoding: encoding,
        flush: flush,
      );
    }
    throw StateError('只有文件才能写入内容: $path');
  }

  /// 读取文件字节
  Future<List<int>> readAsBytes() async {
    if (isFile) {
      final file = _typedEntity as AppFile;
      return await file.readAsBytes();
    }
    throw StateError('只有文件才能读取字节: $path');
  }

  /// 按行读取文件
  Future<List<String>> readAsLines({Encoding encoding = utf8}) async {
    if (isFile) {
      final file = _typedEntity as AppFile;
      return await file.readAsLines(encoding: encoding);
    }
    throw StateError('只有文件才能按行读取: $path');
  }

  // ========== 通用操作 ==========

  /// 删除实体
  Future<bool> delete({bool recursive = false}) async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity).delete();
    } else {
      return await (_typedEntity as AppDirectory).deleteRecursively();
    }
  }

  /// 重命名实体
  Future<AppFileSystemEntity> rename(String newPath) async {
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      final newDirectory = await directory.rename(newPath);
      return AppFileSystemEntity.fromDirectory(newDirectory.directory);
    } else {
      final file = _typedEntity as AppFile;
      final newFile = await file.rename(newPath);
      return AppFileSystemEntity.fromFile(newFile.file);
    }
  }

  /// 复制实体
  Future<AppFileSystemEntity> copyTo(String newPath) async {
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      final newDir = await directory.copyTo(newPath);
      return AppFileSystemEntity.fromDirectory(newDir.directory);
    } else {
      final file = _typedEntity as AppFile;
      final newFile = await file.copy(newPath);
      return AppFileSystemEntity.fromFile(newFile.file);
    }
  }

  /// 移动实体
  Future<AppFileSystemEntity> moveTo(String newPath) async {
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      final newDir = await directory.move(newPath);
      return AppFileSystemEntity.fromDirectory(newDir.directory);
    } else {
      final file = _typedEntity as AppFile;
      final newFile = await file.move(newPath);
      return AppFileSystemEntity.fromFile(newFile.file);
    }
  }

  /// 创建目录（如果不存在）
  Future<AppFileSystemEntity> createIfNotExists({bool recursive = true}) async {
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      await directory.createIfNotExists(recursive: recursive);
      return this;
    }
    throw StateError('只有目录才能创建: $path');
  }

  // ========== 工具方法 ==========

  /// 获取格式化的修改时间
  Future<String> getFormattedModifiedTime() async {
    final dateTime = await modifiedTime;
    if (dateTime == null) return '未知时间';
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }

  /// 获取格式化的创建时间
  Future<String> getFormattedCreatedTime() async {
    final dateTime = await createdTime;
    if (dateTime == null) return '未知时间';
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }

  /// 获取人类可读的大小
  Future<String> getFormattedSize() async {
    if (isFile) {
      return Utils.formatBytes(await fileSize);
    } else {
      return Utils.formatBytes(await directorySize);
    }
  }

  /// 获取人类可读的大小（仅文件）
  Future<String> getFormattedFileSize() async {
    if (isFile) {
      return Utils.formatBytes(await fileSize);
    } else {
      return '';
    }
  }

  /// 获取人类可读的大小（仅目录）
  Future<String> getFormattedDirectorySize() async {
    if (isDirectory) {
      return Utils.formatBytes(await directorySize);
    } else {
      return '';
    }
  }

  /// 获取实体统计信息
  Future<EntityStats> getStats() async {
    if (isFile) {
      final file = _typedEntity as AppFile;
      return EntityStats(
        path: path,
        name: name,
        type: 'file',
        size: await fileSize,
        formattedSize: await getFormattedSize(),
        extension: extension,
        mimeType: file.mimeType,
        fileType: file.fileType,
        modifiedTime: await modifiedTime,
        createdTime: await createdTime,
        isHidden: await isHidden,
        isReadable: await isReadable,
        isWritable: await isWritable,
      );
    } else {
      final directory = _typedEntity as AppDirectory;
      final stats = await directory.stats;
      return EntityStats(
        path: path,
        name: name,
        type: 'directory',
        size: await directorySize,
        formattedSize: await getFormattedSize(),
        extension: '',
        mimeType: null,
        fileType: 'directory',
        modifiedTime: await modifiedTime,
        createdTime: await createdTime,
        isHidden: await isHidden,
        isReadable: await isReadable,
        isWritable: await isWritable,
        fileCount: stats.fileCount,
        directoryCount: stats.directoryCount,
      );
    }
  }

  /// 获取实体信息摘要
  Future<EntityInfo> get info async {
    final stats = await getStats();
    return EntityInfo.fromStats(stats);
  }

  // ========== 高级操作 ==========

  /// 获取目录树形结构
  Future<EntityTree> getTree({int maxDepth = 3}) async {
    if (isDirectory) {
      final directory = _typedEntity as AppDirectory;
      final dirTree = await directory.getTree(maxDepth: maxDepth);

      final List<EntityTree> children = await Future.wait(
        dirTree.children.map((child) async {
          final entity = AppFileSystemEntity.fromDirectory(
            child.directory.directory,
          );
          return EntityTree(
            entity: entity,
            children: await entity
                .getTree(maxDepth: maxDepth - 1)
                .then((tree) => tree.children),
            depth: child.depth,
          );
        }).toList(),
      );

      return EntityTree(entity: this, children: children, depth: dirTree.depth);
    }

    // 文件返回单节点树
    return EntityTree(entity: this, children: [], depth: 0);
  }

  /// 检查实体是否包含指定文本（仅文件有效）
  Future<bool> containsText(String text, {Encoding encoding = utf8}) async {
    if (isFile) {
      final file = _typedEntity as AppFile;
      return await file.containsText(text, encoding: encoding);
    }
    return false;
  }

  /// 获取实体哈希值（仅文件有效）
  Future<String> get md5 async {
    if (isFile) {
      final file = _typedEntity as AppFile;
      return await file.md5;
    }
    return '';
  }

  /// 清除缓存（当实体发生变化时调用）
  void clearCache() {
    _cachedSize = null;
    _cachedModifiedTime = null;
    _cachedCreatedTime = null;
    _cachedIsHidden = null;
    _cachedIsReadable = null;
    _cachedIsWritable = null;
    _cachedType = null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFileSystemEntity && path == other.path;
  }

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() {
    final typeStr = isFile ? 'File' : 'Directory';
    final iconStr = isFile ? '📄' : '📁';
    return '$iconStr $typeStr: $name ($path)';
  }
}

// ========== 辅助数据类 ==========

/// 实体统计信息
class EntityStats {
  final String path; // 路径
  final String name; // 名称
  final String type; // 'file' 或 'directory'
  final int size; // 字节大小
  final String formattedSize; // 格式化大小
  final String extension; // 扩展名
  final String? mimeType; // MIME类型（仅文件有）
  final String fileType; // 文件类型描述（仅文件有）
  final DateTime? modifiedTime; // 修改时间
  final DateTime? createdTime; // 创建时间
  final bool isHidden; // 是否隐藏
  final bool isReadable; // 是否可读
  final bool isWritable; // 是否可写
  final int? fileCount; // 文件数量仅目录有
  final int? directoryCount; // 目录数量仅目录有

  const EntityStats({
    required this.path,
    required this.name,
    required this.type,
    required this.size,
    required this.formattedSize,
    required this.extension,
    required this.mimeType,
    required this.fileType,
    required this.modifiedTime,
    required this.createdTime,
    required this.isHidden,
    required this.isReadable,
    required this.isWritable,
    this.fileCount,
    this.directoryCount,
  });

  @override
  String toString() {
    final modifiedStr = modifiedTime != null
        ? '${modifiedTime!.year}-${modifiedTime!.month.toString().padLeft(2, '0')}-${modifiedTime!.day.toString().padLeft(2, '0')} ${modifiedTime!.hour.toString().padLeft(2, '0')}:${modifiedTime!.minute.toString().padLeft(2, '0')}'
        : '未知时间';

    if (type == 'file') {
      return 'File: $name ($path), Size: $formattedSize, Type: $fileType, Extension: $extension, MIME: ${mimeType ?? '未知'}, Modified: $modifiedStr, Hidden: $isHidden, Readable: $isReadable, Writable: $isWritable';
    } else {
      return 'Directory: $name ($path), Files: $fileCount, Directories: $directoryCount, Size: $formattedSize, Modified: $modifiedStr, Hidden: $isHidden, Readable: $isReadable, Writable: $isWritable';
    }
  }
}

/// 实体信息摘要
class EntityInfo {
  final String path;
  final String name;
  final String type;
  final String formattedSize;
  final String fileType;
  final String formattedModifiedTime;
  final bool isHidden;
  final bool isWritable;

  EntityInfo.fromStats(EntityStats stats)
    : path = stats.path,
      name = stats.name,
      type = stats.type,
      formattedSize = stats.formattedSize,
      fileType = stats.fileType,
      formattedModifiedTime = _formatDateTime(stats.modifiedTime),
      isHidden = stats.isHidden,
      isWritable = stats.isWritable;

  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知时间';
    return '${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
  }

  static String _padZero(int number) => number.toString().padLeft(2, '0');

  @override
  String toString() =>
      '$type: $name, Size: $formattedSize, Modified: $formattedModifiedTime';
}

/// 实体树形结构
class EntityTree {
  final AppFileSystemEntity entity;
  final List<EntityTree> children;
  final int depth;

  const EntityTree({
    required this.entity,
    required this.children,
    required this.depth,
  });

  Future<void> printTree({String indent = ''}) async {
    final isDir = entity.isDirectory;
    final icon = isDir ? '📁' : '📄';
    print('$indent$icon ${entity.name}');

    for (int i = 0; i < children.length; i++) {
      final isLast = i == children.length - 1;
      final newIndent = '$indent${isLast ? '  ' : '│ '}';
      await children[i].printTree(indent: newIndent);
    }
  }
}

// ========== 扩展方法 ==========

/// 为原生实体添加便捷转换
extension FileSystemEntityExtensions on FileSystemEntity {
  AppFileSystemEntity get asAppEntity => AppFileSystemEntity._internal(this);
}

extension FileExtensions on File {
  AppFileSystemEntity get asAppEntity => AppFileSystemEntity.fromFile(this);
}

extension DirectoryExtensions on Directory {
  AppFileSystemEntity get asAppEntity =>
      AppFileSystemEntity.fromDirectory(this);
}

extension AppFileExtensions on AppFile {
  AppFileSystemEntity get asAppEntity => AppFileSystemEntity.fromAppFile(this);
}

extension AppDirectoryExtensions on AppDirectory {
  AppFileSystemEntity get asAppEntity =>
      AppFileSystemEntity.fromAppDirectory(this);
}
