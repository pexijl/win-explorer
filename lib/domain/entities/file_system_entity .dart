// 表示目录中的一个项目，可以是文件或子目录。
class FileSystemEntity {
  final String name;
  final String path;
  final int size; // 对于文件是大小，对于目录通常是其下所有内容的总大小
  final bool isDirectory; // true 表示是目录，false 表示是文件
  final DateTime? modifiedTime;

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