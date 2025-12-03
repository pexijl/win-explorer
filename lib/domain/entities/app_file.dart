import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path_utils;
import 'package:mime/mime.dart' as mime;
import 'package:crypto/crypto.dart' as crypto;

/// 增强的文件类（组合模式）
/// 封装 File 并提供文件管理器所需的高级功能
class AppFile {
  final File _file;

  AppFile._internal(this._file);

  // ========== 工厂构造函数 ==========

  /// 从路径创建 AppFile
  factory AppFile(String path) {
    return AppFile._internal(File(path));
  }

  /// 从原生 File 对象创建
  factory AppFile.fromFile(File file) {
    return AppFile._internal(file);
  }

  /// 从 FileSystemEntity 创建（如果是文件）
  factory AppFile.fromFileSystemEntity(FileSystemEntity entity) {
    if (entity is File) {
      return AppFile._internal(entity);
    }
    throw ArgumentError('实体不是文件: ${entity.path}');
  }

  // ========== 基础属性 ==========

  /// 获取底层 File 对象
  File get file => _file;

  /// 获取文件路径
  String get path => _file.path;

  /// 获取文件名（包含扩展名）
  String get name => path_utils.basename(path);

  /// 获取文件名（不包含扩展名）
  String get nameWithoutExtension => path_utils.basenameWithoutExtension(path);

  /// 获取文件扩展名（小写，包含点）
  String get extension => path_utils.extension(path).toLowerCase();

  /// 获取父目录路径
  String get parentPath => path_utils.dirname(path);

  // ========== 状态检查 ==========

  /// 检查文件是否存在
  Future<bool> get exists async => await _file.exists();

  /// 检查文件是否为空
  Future<bool> get isEmpty async => (await size) == 0;

  /// 检查文件是否可读
  Future<bool> get isReadable async {
    try {
      return await exists;
    } catch (e) {
      return false;
    }
  }

  /// 检查文件是否可写
  Future<bool> get isWritable async {
    try {
      // 尝试以追加模式打开文件测试可写性
      final raf = await _file.open(mode: FileMode.append);
      await raf.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 检查文件是否可执行
  Future<bool> get isExecutable async {
    try {
      if (Platform.isWindows) {
        // Windows: 检查文件扩展名
        final execExtensions = ['.exe', '.bat', '.cmd', '.com', '.msi'];
        return execExtensions.contains(extension);
      } else {
        // Unix-like: 检查执行权限
        final stat = await _file.stat();
        return stat.mode & 0x49 != 0; // 检查用户、组、其他的执行权限
      }
    } catch (e) {
      return false;
    }
  }

  /// 检查文件是否隐藏（以点开头）
  Future<bool> get isHidden async {
    try {
      return name.startsWith('.');
    } catch (e) {
      return false;
    }
  }

  // ========== 文件信息 ==========

  /// 获取文件大小（字节）
  Future<int> get size async {
    try {
      final stat = await _file.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  /// 获取最后修改时间
  Future<DateTime?> get modifiedTime async {
    try {
      final stat = await _file.stat();
      return stat.modified;
    } catch (e) {
      return null;
    }
  }

  /// 获取创建时间
  Future<DateTime?> get createdTime async {
    try {
      final stat = await _file.stat();
      return stat.changed;
    } catch (e) {
      return null;
    }
  }

  /// 获取最后访问时间
  Future<DateTime?> get accessedTime async {
    try {
      final stat = await _file.stat();
      return stat.accessed;
    } catch (e) {
      return null;
    }
  }

  /// 获取文件权限模式（Unix-like 系统）
  Future<int> get mode async {
    try {
      final stat = await _file.stat();
      return stat.mode;
    } catch (e) {
      return 0;
    }
  }

  // ========== 文件类型检测 ==========

  /// 获取文件 MIME 类型
  String? get mimeType {
    try {
      return mime.lookupMimeType(path);
    } catch (e) {
      return null;
    }
  }

  /// 获取文件类型分类
  String get fileType {
    final mime = mimeType;
    if (mime == null) return 'unknown';

    if (mime.startsWith('image/')) return 'image';
    if (mime.startsWith('video/')) return 'video';
    if (mime.startsWith('audio/')) return 'audio';
    if (mime.startsWith('text/')) return 'text';
    if (mime == 'application/pdf') return 'pdf';
    if (mime.contains('word') || mime.contains('document')) return 'document';
    if (mime.contains('zip') || mime.contains('archive')) return 'archive';
    if (mime.contains('code') || _isCodeFile()) return 'code';

    return 'file';
  }

  /// 获取显示用的图标类型
  String get iconType {
    final type = fileType;
    switch (type) {
      case 'image':
        return 'image';
      case 'video':
        return 'video';
      case 'audio':
        return 'audio';
      case 'text':
        return 'document';
      case 'pdf':
        return 'pdf';
      case 'document':
        return 'document';
      case 'archive':
        return 'archive';
      case 'code':
        return 'code';
      default:
        return 'file';
    }
  }

  /// 检查是否是代码文件
  bool _isCodeFile() {
    const codeExtensions = [
      '.dart',
      '.java',
      '.cpp',
      '.c',
      '.h',
      '.hpp',
      '.py',
      '.js',
      '.ts',
      '.html',
      '.css',
      '.xml',
      '.json',
      '.yaml',
      '.yml',
      '.md',
      '.sql',
    ];
    return codeExtensions.contains(extension);
  }

  /// 检查是否是图片文件
  bool get isImage => fileType == 'image';

  /// 检查是否是视频文件
  bool get isVideo => fileType == 'video';

  /// 检查是否是音频文件
  bool get isAudio => fileType == 'audio';

  /// 检查是否是文本文件
  bool get isText => fileType == 'text';

  /// 检查是否是 PDF 文件
  bool get isPdf => fileType == 'pdf';

  /// 检查是否是代码文件
  bool get isCode => fileType == 'code';

  /// 检查是否是文档文件
  bool get isDocument {
    const docExtensions = ['.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx'];
    return docExtensions.contains(extension) || fileType == 'document';
  }

  /// 检查是否是压缩文件
  bool get isArchive {
    const archiveExtensions = ['.zip', '.rar', '.7z', '.tar', '.gz', '.bz2'];
    return archiveExtensions.contains(extension) || fileType == 'archive';
  }

  // ========== 文件内容操作 ==========

  /// 读取文件内容为字符串
  Future<String> readAsString({Encoding encoding = utf8}) async {
    try {
      return await _file.readAsString(encoding: encoding);
    } catch (e) {
      throw Exception('读取文件失败: $e');
    }
  }

  /// 读取文件内容为字节列表
  Future<List<int>> readAsBytes() async {
    try {
      return await _file.readAsBytes();
    } catch (e) {
      throw Exception('读取文件失败: $e');
    }
  }

  /// 按行读取文件内容
  Future<List<String>> readAsLines({Encoding encoding = utf8}) async {
    try {
      return await _file.readAsLines(encoding: encoding);
    } catch (e) {
      throw Exception('读取文件失败: $e');
    }
  }

  /// 写入字符串到文件
  Future<void> writeAsString(
    String content, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    try {
      await _file.writeAsString(
        content,
        mode: mode,
        encoding: encoding,
        flush: flush,
      );
    } catch (e) {
      throw Exception('写入文件失败: $e');
    }
  }

  /// 写入字节到文件
  Future<void> writeAsBytes(
    List<int> bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async {
    try {
      await _file.writeAsBytes(bytes, mode: mode, flush: flush);
    } catch (e) {
      throw Exception('写入文件失败: $e');
    }
  }

  /// 追加内容到文件
  Future<void> appendString(String content, {Encoding encoding = utf8}) async {
    try {
      await writeAsString(content, mode: FileMode.append, encoding: encoding);
    } catch (e) {
      throw Exception('追加文件失败: $e');
    }
  }

  /// 追加字节到文件
  Future<void> appendBytes(List<int> bytes) async {
    try {
      await writeAsBytes(bytes, mode: FileMode.append);
    } catch (e) {
      throw Exception('追加文件失败: $e');
    }
  }

  // ========== 文件操作 ==========

  /// 复制文件到新位置
  Future<AppFile> copy(String newPath) async {
    try {
      final newFile = await _file.copy(newPath);
      return AppFile.fromFile(newFile);
    } catch (e) {
      throw Exception('复制文件失败: $e');
    }
  }

  /// 复制文件到目录
  Future<AppFile> copyToDirectory(String directoryPath) async {
    final newPath = path_utils.join(directoryPath, name);
    return await copy(newPath);
  }

  /// 移动文件到新位置
  Future<AppFile> move(String newPath) async {
    try {
      final newFile = await _file.rename(newPath);
      return AppFile.fromFile(newFile);
    } catch (e) {
      throw Exception('移动文件失败: $e');
    }
  }

  /// 移动文件到目录
  Future<AppFile> moveToDirectory(String directoryPath) async {
    final newPath = path_utils.join(directoryPath, name);
    return await move(newPath);
  }

  /// 重命名文件
  Future<AppFile> rename(String newName) async {
    final newPath = path_utils.join(parentPath, newName);
    return await move(newPath);
  }

  /// 删除文件
  Future<bool> delete() async {
    try {
      await _file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 安全删除文件（检查存在性）
  Future<bool> deleteIfExists() async {
    try {
      if (await exists) {
        await _file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 创建文件的符号链接
  Future<AppFile> createSymbolicLink(String linkPath) async {
    try {
      await Link(linkPath).create(_file.path); // 使用 Link 类创建符号链接
      return AppFile(linkPath);
    } catch (e) {
      throw Exception('创建符号链接失败: $e');
    }
  }

  // ========== 文件内容检查 ==========

  /// 检查文件内容是否包含指定文本
  Future<bool> containsText(String text, {Encoding encoding = utf8}) async {
    try {
      final content = await readAsString(encoding: encoding);
      return content.contains(text);
    } catch (e) {
      return false;
    }
  }

  /// 获取文件内容的 MD5 哈希值
  Future<String> get md5 async {
    try {
      final bytes = await _file.readAsBytes();
      final digest = crypto.md5.convert(bytes);
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  /// 获取文件内容的 SHA256 哈希值
  Future<String> get sha256 async {
    try {
      final bytes = await readAsBytes();
      final digest = crypto.sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  /// 比较两个文件内容是否相同
  Future<bool> contentEquals(AppFile other) async {
    try {
      if (await size != await other.size) return false;
      final thisMd5 = await md5;
      final otherMd5 = await other.md5;
      return thisMd5 == otherMd5;
    } catch (e) {
      return false;
    }
  }

  // ========== 工具方法 ==========

  /// 获取人类可读的文件大小
  Future<String> getFormattedSize() async {
    final bytes = await size;
    return _formatBytes(bytes);
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

  /// 获取文件信息摘要
  Future<FileInfo> get info async {
    return FileInfo(
      path: path,
      name: name,
      size: await size,
      formattedSize: await getFormattedSize(),
      extension: extension,
      mimeType: mimeType,
      fileType: fileType,
      modifiedTime: await modifiedTime,
      createdTime: await createdTime,
      isHidden: await isHidden,
      isReadable: await isReadable,
      isWritable: await isWritable,
    );
  }

  /// 打开文件流进行逐块读取（适合大文件）
  Stream<List<int>> openRead([int? start, int? end]) {
    return _file.openRead(start, end);
  }

  /// 打开文件流进行逐块写入（适合大文件）
  IOSink openWrite({FileMode mode = FileMode.write, Encoding encoding = utf8}) {
    return _file.openWrite(mode: mode, encoding: encoding);
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes == 0) return '0 B';

    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(unitIndex > 0 ? 1 : 0)} ${units[unitIndex]}';
  }

  String _formatTime(DateTime time) {
    return '${_padZero(time.hour)}:${_padZero(time.minute)}';
  }

  String _padZero(int number) => number.toString().padLeft(2, '0');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFile &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'AppFile{path: $path, name: $name}';
}

// ========== 辅助数据类 ==========

/// 文件信息摘要
class FileInfo {
  final String path;
  final String name;
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

  const FileInfo({
    required this.path,
    required this.name,
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
  });

  @override
  String toString() =>
      'FileInfo{name: $name, size: $formattedSize, type: $fileType}';
}

/// 文件操作结果
class FileOperationResult {
  final bool success;
  final String message;
  final dynamic data;

  const FileOperationResult({
    required this.success,
    required this.message,
    this.data,
  });
}

/// 扩展方法，为原生 File 添加便捷转换
extension FileExtensions on File {
  AppFile get asAppFile => AppFile.fromFile(this);
}

/// 扩展方法，为字符串路径添加便捷转换
extension StringPathExtensions on String {
  AppFile get asAppFile => AppFile(this);
}
