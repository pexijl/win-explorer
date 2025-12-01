import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path_utils;
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/app_file.dart';

/// 应用文件系统实体类（组合模式）
/// 使用 AppFile 和 AppDirectory 共同实现，提供统一接口
class AppFileSystemEntity {
  final FileSystemEntity _fileSystemEntity; // 底层实体
  late final dynamic _typedEntity; // 可以是 AppFile 或 AppDirectory

  AppFileSystemEntity._internal(this._fileSystemEntity) {
    // 根据类型初始化对应的实体
    if (_fileSystemEntity is File) {
      _typedEntity = AppFile.fromFile(_fileSystemEntity);
    } else if (_fileSystemEntity is Directory) {
      _typedEntity = AppDirectory.fromDirectory(_fileSystemEntity);
    } else {
      throw UnsupportedError('不支持的实体类型: ${_fileSystemEntity.runtimeType}');
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
  factory AppFileSystemEntity.fromFileSystemEntity(
      FileSystemEntity entity) {
    return AppFileSystemEntity._internal(entity);
  }

  // ========== 类型检查和转换 ==========

  /// 获取实体类型
  Future<FileSystemEntityType> get type async {
    return await FileSystemEntity.type(path);
  }

  /// 检查是否是文件
  Future<bool> get isFile async => await type == FileSystemEntityType.file;

  /// 检查是否是目录
  Future<bool> get isDirectory async =>
      await type == FileSystemEntityType.directory;

  /// 转换为 AppFile（如果是文件）
  AppFile? get asAppFile =>
      _typedEntity is AppFile ? _typedEntity as AppFile : null;

  /// 转换为 AppDirectory（如果是目录）
  AppDirectory? get asAppDirectory =>
      _typedEntity is AppDirectory ? _typedEntity as AppDirectory : null;

  /// 安全转换为 AppFile
  Future<AppFile> toAppFile() async {
    if (await isFile) {
      return _typedEntity as AppFile;
    }
    throw StateError('实体不是文件: $path');
  }

  /// 安全转换为 AppDirectory
  Future<AppDirectory> toAppDirectory() async {
    if (await isDirectory) {
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
      return await (_typedEntity as AppFile).exists;
    } else {
      return await (_typedEntity as AppDirectory).exists;
    }
  }

  /// 检查是否为空
  Future<bool> get isEmpty async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).isEmpty;
    } else {
      return await (_typedEntity as AppDirectory).isEmpty;
    }
  }

  /// 检查是否可读
  Future<bool> get isReadable async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).isReadable;
    } else {
      return await (_typedEntity as AppDirectory).isReadable;
    }
  }

  /// 检查是否可写
  Future<bool> get isWritable async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).isWritable;
    } else {
      return await (_typedEntity as AppDirectory).isWritable;
    }
  }

  /// 检查是否隐藏
  Future<bool> get isHidden async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).isHidden;
    } else {
      return await (_typedEntity as AppDirectory).isHidden;
    }
  }

  // ========== 文件信息（委托给具体实现） ==========

  /// 获取实体大小
  Future<int> get size async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).size;
    } else {
      return await (_typedEntity as AppDirectory).size;
    }
  }

  /// 获取最后修改时间
  Future<DateTime?> get modifiedTime async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).modifiedTime;
    } else {
      return await (_typedEntity as AppDirectory).modifiedTime;
    }
  }

  /// 获取创建时间
  Future<DateTime?> get createdTime async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).createdTime;
    } else {
      return await (_typedEntity as AppDirectory).createdTime;
    }
  }

  /// 获取显示用的图标类型
  Future<String> get iconType async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).iconType;
    } else {
      return 'folder'; // 目录固定返回文件夹图标
    }
  }

  // ========== 目录操作（仅目录有效） ==========

  /// 获取目录的子项
  Future<List<AppFileSystemEntity>> getChildren() async {
    if (await isDirectory) {
      final directory = _typedEntity as AppDirectory;
      final entities = await directory.listEntities();

      final children = <AppFileSystemEntity>[];
      for (final entity in entities) {
        children.add(AppFileSystemEntity._internal(entity as FileSystemEntity));
      }

      return children;
    }
    throw StateError('只有目录才能获取子项: $path');
  }

  /// 获取目录下的所有文件
  Future<List<AppFileSystemEntity>> getAllFiles({bool recursive = true}) async {
    if (await isDirectory) {
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
    if (await isDirectory) {
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
    if (await isDirectory) {
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
    if (await isFile) {
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
    if (await isFile) {
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
    if (await isFile) {
      final file = _typedEntity as AppFile;
      return await file.readAsBytes();
    }
    throw StateError('只有文件才能读取字节: $path');
  }

  /// 按行读取文件
  Future<List<String>> readAsLines({Encoding encoding = utf8}) async {
    if (await isFile) {
      final file = _typedEntity as AppFile;
      return await file.readAsLines(encoding: encoding);
    }
    throw StateError('只有文件才能按行读取: $path');
  }

  // ========== 通用操作 ==========

  /// 删除实体
  Future<bool> delete({bool recursive = false}) async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).delete();
    } else {
      return await (_typedEntity as AppDirectory).deleteRecursively();
    }
  }

  /// 重命名实体
  Future<AppFileSystemEntity> rename(String newPath) async {
    FileSystemEntity newEntity;

    if (_typedEntity is AppFile) {
      final file = _typedEntity as AppFile;
      newEntity = (await file.rename(newPath)) as FileSystemEntity;
    } else {
      final directory = _typedEntity as AppDirectory;
      newEntity = (await directory.rename(newPath)) as FileSystemEntity;
    }

    return AppFileSystemEntity._internal(newEntity);
  }

  /// 复制实体
  Future<AppFileSystemEntity> copyTo(String newPath) async {
    if (_typedEntity is AppFile) {
      final file = _typedEntity as AppFile;
      final newFile = await file.copy(newPath);
      return AppFileSystemEntity.fromFile(newFile as File);
    } else {
      final directory = _typedEntity as AppDirectory;
      final newDir = await directory.copyTo(newPath);
      return AppFileSystemEntity.fromDirectory(newDir.directory);
    }
  }

  /// 创建目录（如果不存在）
  Future<AppFileSystemEntity> createIfNotExists({bool recursive = true}) async {
    if (await isDirectory) {
      final directory = _typedEntity as AppDirectory;
      await directory.createIfNotExists(recursive: recursive);
      return this;
    }
    throw StateError('只有目录才能创建: $path');
  }

  // ========== 工具方法 ==========

  /// 获取人类可读的大小
  Future<String> getFormattedSize() async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).getFormattedSize();
    } else {
      return await (_typedEntity as AppDirectory).getFormattedSize();
    }
  }

  /// 获取格式化的修改时间
  Future<String> getFormattedModifiedTime() async {
    if (_typedEntity is AppFile) {
      return await (_typedEntity as AppFile).getFormattedModifiedTime();
    } else {
      return await (_typedEntity as AppDirectory).getFormattedModifiedTime();
    }
  }

  /// 获取实体统计信息
  Future<EntityStats> getStats() async {
    if (await isFile) {
      final file = _typedEntity as AppFile;
      final info = await file.info;
      return EntityStats(
        path: path,
        name: name,
        type: 'file',
        size: await size,
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
        size: await size,
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
    if (await isDirectory) {
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
    if (await isFile) {
      final file = _typedEntity as AppFile;
      return await file.containsText(text, encoding: encoding);
    }
    return false;
  }

  /// 获取实体哈希值（仅文件有效）
  Future<String> get md5 async {
    if (await isFile) {
      final file = _typedEntity as AppFile;
      return await file.md5;
    }
    return '';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFileSystemEntity &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() {
    final typeStr = _typedEntity is AppFile ? 'File' : 'Directory';
    return 'AppFileSystemEntity{$typeStr: $path}';
  }
}

// ========== 辅助数据类 ==========

/// 实体统计信息
class EntityStats {
  final String path;
  final String name;
  final String type; // 'file' 或 'directory'
  final int size;
  final String formattedSize;
  final String extension;
  final String? mimeType;
  final String fileType;
  final DateTime? modifiedTime;
  final DateTime? createdTime;
  final bool isHidden;
  final bool isReadable;
  final bool isWritable;
  final int? fileCount; // 仅目录有
  final int? directoryCount; // 仅目录有

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
    if (type == 'file') {
      return 'File: $name, Size: $formattedSize, Type: $fileType';
    } else {
      return 'Directory: $name, Files: $fileCount, Size: $formattedSize';
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
    final isDir = await entity.isDirectory;
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
