import 'dart:ffi'; // 使用 Dart 的 FFI 功能
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';
import 'package:win_explorer/data/services/win32_service.dart'; // 引入 win32 包

void main() {
  test('win32_test', () {
    getDriveList();
  });

  test('win32_test_2', () {
    printDetailedDriveInfo();
  });

  test('win32_test_3', () {
    getDriveListByWin32();
  });
}



void printDetailedDriveInfo() {
  final driveBitMask = GetLogicalDrives();

  for (int i = 0; i < 26; i++) {
    if ((driveBitMask & (1 << i)) != 0) {
      String driveLetter = String.fromCharCode('A'.codeUnitAt(0) + i);
      String rootPath = '$driveLetter:\\'; // 例如 "C:\\"

      // 调用 GetDriveType 获取驱动器类型
      int driveType = GetDriveType(Pointer.fromAddress(rootPath.toNativeUtf16().address));

      String typeDescription;
      switch (driveType) {
        case DRIVE_UNKNOWN:
          typeDescription = '类型未知';
          break;
        case DRIVE_NO_ROOT_DIR:
          typeDescription = '路径无效';
          break;
        case DRIVE_REMOVABLE:
          typeDescription = '可移动磁盘 (如U盘)';
          break;
        case DRIVE_FIXED:
          typeDescription = '本地硬盘';
          break;
        case DRIVE_REMOTE:
          typeDescription = '网络驱动器';
          break;
        case DRIVE_CDROM:
          typeDescription = '光盘驱动器';
          break;
        case DRIVE_RAMDISK:
          typeDescription = 'RAM磁盘';
          break;
        default:
          typeDescription = '未知类型';
      }

      print('驱动器 $rootPath - $typeDescription');
    }
  }
}


void getDriveList() { 
  final driveBitMask = GetLogicalDrives();

  if (driveBitMask == 0) {
    print('获取驱动器列表失败。');
    return;
  }

  List<String> drives = [];

  for (int i = 0; i < 26; i++) {
    if ((driveBitMask & (1 << i)) != 0) {
      String driveLetter = String.fromCharCode('A'.codeUnitAt(0) + i);
      drives.add('$driveLetter:\\');
    }
  }

  print('系统上的逻辑驱动器:');
  print(drives);
}

void getDriveListByWin32() { 
  List<String> drives = Win32Service().getDriveList();
  print('系统上的逻辑驱动器 (通过 Win32Service):');
  print(drives);
}