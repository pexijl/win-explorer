import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

// 定义一个纯 Dart 类，用于向上层传递数据，避免 UI 层接触 FFI
class Win32FileAttribute {
  final String displayName; // Windows 显示的名称（可能隐藏了后缀）
  final String typeName; // 文件类型描述 (例如 "Text Document")
  final bool isHidden; // 是否是隐藏文件

  Win32FileAttribute({
    required this.displayName,
    required this.typeName,
    required this.isHidden,
  });
}

class Win32Service {
  static const INVALID_FILE_ATTRIBUTES = -1;
  // 单例模式 (可选，方便全局调用)
  static final Win32Service _instance = Win32Service._internal();
  factory Win32Service() => _instance;
  Win32Service._internal();

  /// 获取文件的 Windows 特定属性
  /// [path] 文件的绝对路径
  Win32FileAttribute getFileDetail(String path) {
    // 1. 分配内存：SHFILEINFO 结构体用于接收结果
    final pServerInfo = calloc<SHFILEINFO>();

    // 2. 将 Dart String 转换为 Windows 需要的 UTF-16 字符串指针 (LPCWSTR)
    final pPath = path.toNativeUtf16();

    try {
      // 3. 调用 Windows API: SHGetFileInfo
      // SHGFI_TYPENAME: 获取类型名称
      // SHGFI_DISPLAYNAME: 获取显示名称
      final result = SHGetFileInfo(
        pPath,
        0, // 文件属性，通常为 0 或 FILE_ATTRIBUTE_NORMAL
        pServerInfo,
        sizeOf<SHFILEINFO>(),
        SHGFI_TYPENAME | SHGFI_DISPLAYNAME,
      );

      if (result == 0) {
        // 如果调用失败，返回默认值
        return Win32FileAttribute(
          displayName: '',
          typeName: 'Unknown',
          isHidden: false,
        );
      }

      // 4. 读取结构体数据并转换为 Dart String
      // szDisplayName 和 szTypeName 是固定长度的数组，win32 库已封装好 getter
      final displayName = pServerInfo.ref.szDisplayName;
      final typeName = pServerInfo.ref.szTypeName;

      // 5. 额外演示：检查文件是否隐藏 (使用 GetFileAttributes)
      final attributes = GetFileAttributes(pPath);
      final isHidden =
          (attributes != INVALID_FILE_ATTRIBUTES) &&
          (attributes & FILE_ATTRIBUTE_HIDDEN != 0);

      return Win32FileAttribute(
        displayName: displayName,
        typeName: typeName,
        isHidden: isHidden,
      );
    } finally {
      // 6. 务必释放内存！
      free(pServerInfo);
      free(pPath);
    }
  }

  /// 示例：获取磁盘卷标 (例如 "本地磁盘 (C:)")
  String getDriveLabel(String drivePath) {
    // drivePath 必须是以反斜杠结尾，例如 "C:\"
    final pRootPathName = drivePath.toNativeUtf16();
    final pVolumeNameBuffer = wsalloc(MAX_PATH); // 分配 MAX_PATH 长度的缓冲区

    try {
      final result = GetVolumeInformation(
        pRootPathName,
        pVolumeNameBuffer,
        MAX_PATH,
        nullptr, // 不需要序列号
        nullptr,
        nullptr,
        nullptr, // 不需要文件系统名称
        0,
      );

      if (result != 0) {
        return pVolumeNameBuffer.toDartString();
      }
      return "Local Disk";
    } finally {
      free(pRootPathName);
      free(pVolumeNameBuffer);
    }
  }

  List<String> getDriveList() {
    final driveBitMask = GetLogicalDrives();

    if (driveBitMask == 0) {
      return [];
    }

    List<String> drives = [];

    for (int i = 0; i < 26; i++) {
      if ((driveBitMask & (1 << i)) != 0) {
        String driveLetter = String.fromCharCode('A'.codeUnitAt(0) + i);
        drives.add('$driveLetter:\\');
      }
    }
    return drives;
  }
}
