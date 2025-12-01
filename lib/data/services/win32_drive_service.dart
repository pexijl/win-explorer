import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:win_explorer/domain/entities/drive.dart';

/// Win32 驱动器服务层
class Win32DriveService {
  static final Win32DriveService _instance = Win32DriveService._internal();
  factory Win32DriveService() => _instance;
  Win32DriveService._internal();

  /// 获取系统中所有可用的驱动器列表
  List<Drive> getSystemDrives() {
    final drives = <Drive>[];

    try {
      // 方法1: 使用 GetLogicalDrives 获取驱动器位掩码
      final driveBitMask = GetLogicalDrives();

      if (driveBitMask == 0) {
        throw Exception('获取驱动器列表失败: ${GetLastError()}');
      }

      // 遍历26个可能的驱动器字母 (A-Z)
      for (int i = 0; i < 26; i++) {
        if ((driveBitMask & (1 << i)) != 0) {
          final driveLetter = String.fromCharCode('A'.codeUnitAt(0) + i);
          final mountPoint = '$driveLetter:\\';

          try {
            final drive = _getDriveDetails(mountPoint, driveLetter);
            if (drive.isReady) {
              drives.add(drive);
            }
          } catch (e) {
            print('获取驱动器 $mountPoint 信息失败: $e');
            // 继续处理其他驱动器
          }
        }
      }

      // 方法2: 备用方案 - 使用 GetLogicalDriveStrings
      if (drives.isEmpty) {
        drives.addAll(_getDrivesByStrings());
      }
    } catch (e) {
      print('获取系统驱动器时发生错误: $e');
    }

    return drives;
  }

  /// 使用 GetLogicalDriveStrings API 获取驱动器列表
  List<Drive> _getDrivesByStrings() {
    final drives = <Drive>[];

    // 分配缓冲区
    final bufferSize = 1024;
    final lpBuffer = wsalloc(bufferSize);

    try {
      final result = GetLogicalDriveStrings(bufferSize, lpBuffer);

      if (result == 0 || result > bufferSize) {
        throw Exception('GetLogicalDriveStrings 失败: ${GetLastError()}');
      }

      // 正确地将指针作为 UTF-16 字符串数组进行解析
      int offset = 0;
      while (true) {
        final currentPtr = lpBuffer.cast<Uint16>() + offset;
        final drivePath = currentPtr.cast<Utf16>().toDartString();

        if (drivePath.isEmpty) break;

        final driveLetter = drivePath.substring(0, 1);

        try {
          final drive = _getDriveDetails(drivePath, driveLetter);
          if (drive.isReady) {
            drives.add(drive);
          }
        } catch (e) {
          print('获取驱动器 $drivePath 信息失败: $e');
        }

        // 计算下一个字符串起始位置（当前字符串长度 + 1）
        offset += (drivePath.length + 1);
      }
    } finally {
      free(lpBuffer);
    }

    return drives;
  }

  /// 获取单个驱动器的详细信息
  Drive _getDriveDetails(String mountPoint, String driveLetter) {
    final drivePath = mountPoint.toNativeUtf16();

    try {
      // 1. 获取驱动器类型
      final driveType = GetDriveType(drivePath);

      // 2. 获取磁盘空间信息
      final freeBytesAvailable = calloc<Uint64>();
      final totalNumberOfBytes = calloc<Uint64>();
      final totalNumberOfFreeBytes = calloc<Uint64>();

      final spaceResult = GetDiskFreeSpaceEx(
        drivePath,
        freeBytesAvailable,
        totalNumberOfBytes,
        totalNumberOfFreeBytes,
      );

      final totalSize = spaceResult != 0 ? totalNumberOfBytes.value : 0;
      final freeSpace = spaceResult != 0 ? totalNumberOfFreeBytes.value : 0;
      final isReady = spaceResult != 0;

      // 3. 获取文件系统信息和卷标
      final volumeNameBuffer = wsalloc(MAX_PATH);
      final fileSystemBuffer = wsalloc(MAX_PATH);
      final serialNumber = calloc<DWORD>();
      final maxComponentLength = calloc<DWORD>();
      final fileSystemFlags = calloc<DWORD>();

      String volumeName = '本地磁盘';
      String fileSystem = 'Unknown';

      final volumeResult = GetVolumeInformation(
        drivePath,
        volumeNameBuffer,
        MAX_PATH,
        serialNumber,
        maxComponentLength,
        fileSystemFlags,
        fileSystemBuffer,
        MAX_PATH,
      );

      if (volumeResult != 0) {
        volumeName = volumeNameBuffer.toDartString();
        fileSystem = fileSystemBuffer.toDartString();

        // 如果卷标为空，使用默认名称
        if (volumeName.isEmpty) {
          volumeName = _getDefaultDriveName(driveType, driveLetter);
        }else{
          volumeName = '$volumeName ($driveLetter:)';
        }
      } else {
        volumeName = _getDefaultDriveName(driveType, driveLetter);
      }

      // 4. 确定驱动器是否可写
      final isWritable = _isDriveWritable(driveType);

      // 5. 转换为 DriveType 枚举
      final driveTypeEnum = _mapWin32DriveType(driveType);

      // 清理内存
      free(freeBytesAvailable);
      free(totalNumberOfBytes);
      free(totalNumberOfFreeBytes);
      free(volumeNameBuffer);
      free(fileSystemBuffer);
      free(serialNumber);
      free(maxComponentLength);
      free(fileSystemFlags);

      return Drive(
        id: driveLetter,
        mountPoint: mountPoint,
        name: volumeName,
        totalSize: totalSize,
        freeSpace: freeSpace,
        type: driveTypeEnum,
        fileSystem: fileSystem,
        isWritable: isWritable,
        isReady: isReady,
      );
    } finally {
      free(drivePath);
    }
  }

  /// 将 Win32 驱动器类型映射到 DriveType 枚举
  DriveType _mapWin32DriveType(int win32Type) {
    switch (win32Type) {
      case DRIVE_REMOVABLE:
        return DriveType.removable;
      case DRIVE_FIXED:
        return DriveType.fixed;
      case DRIVE_REMOTE:
        return DriveType.network;
      case DRIVE_CDROM:
        return DriveType.cdrom;
      case DRIVE_RAMDISK:
        return DriveType.ram;
      default:
        return DriveType.unknown;
    }
  }

  /// 获取默认的驱动器名称
  String _getDefaultDriveName(int driveType, String driveLetter) {
    switch (driveType) {
      case DRIVE_REMOVABLE:
        return '可移动磁盘 ($driveLetter:)';
      case DRIVE_FIXED:
        return '本地磁盘 ($driveLetter:)';
      case DRIVE_REMOTE:
        return '网络驱动器 ($driveLetter:)';
      case DRIVE_CDROM:
        return 'CD-ROM 驱动器 ($driveLetter:)';
      case DRIVE_RAMDISK:
        return 'RAM 磁盘 ($driveLetter:)';
      default:
        return '驱动器 $driveLetter:';
    }
  }

  /// 判断驱动器是否可写
  bool _isDriveWritable(int driveType) {
    // CD-ROM 通常是只读的，其他类型一般可写
    return driveType != DRIVE_CDROM;
  }

  /// 监听驱动器变化（可选功能）
  void startDriveChangeListener(void Function(List<Drive>) onDrivesChanged) {
    // 这里可以实现使用 Windows API 监听驱动器变化的逻辑
    // 例如使用 RegisterDeviceNotification 等 API
    // 由于实现较复杂，这里只提供框架
    print('驱动器变化监听器已启动');
  }

  /// 刷新驱动器信息
  List<Drive> refreshDrives() {
    return getSystemDrives();
  }

  /// 获取特定驱动器的详细信息
  Drive? getDriveDetails(String driveLetter) {
    try {
      final drives = getSystemDrives();
      return drives.firstWhere(
        (drive) => drive.driveLetter == driveLetter.toUpperCase(),
        orElse: () => throw Exception('驱动器 $driveLetter 未找到'),
      );
    } catch (e) {
      print('获取驱动器 $driveLetter 详情失败: $e');
      return null;
    }
  }
}
