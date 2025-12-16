class Utils {
  /// 格式化字节数为可读字符串
  static String formatBytes(int bytes) {
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
}
