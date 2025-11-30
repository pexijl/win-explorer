/// 文件系统实体类
/// 
/// 表示文件系统中的一个文件或目录。
/// 用于封装文件/目录的基本属性，如名称、路径、大小、类型
class FileSystemEntity {
  final String name; /// 文件或目录的名称
  final String path; // 文件或目录的完整路径
  final int size; /// 文件或目录的大小，单位为字节
  final bool isDirectory;  /// 文件或目录是否为目录
  final DateTime? modifiedTime; /// 文件或目录的修改时间

  FileSystemEntity({
    required this.name,
    required this.path,
    required this.size,
    required this.isDirectory,
    this.modifiedTime,
  });

  @override
  String toString() {
    // 格式化修改时间（如果存在）
    String modified = modifiedTime != null 
        ? modifiedTime!.toString().split('.').first // 去掉毫秒，简化显示
        : '未获取';
    
    // 格式化大小（区分文件/目录，目录可标注“目录大小”）
    String sizeStr = isDirectory 
        ? '目录总大小: $size 字节' 
        : '文件大小: $size 字节';

    return 'FileSystemEntity{\n'
        '  名称: $name,\n'
        '  类型: ${isDirectory ? '目录' : '文件'},\n'
        '  路径: $path,\n'
        '  $sizeStr,\n'
        '  修改时间: $modified\n'
        '}';
  }
}