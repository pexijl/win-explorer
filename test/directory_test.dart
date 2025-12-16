import 'package:flutter_test/flutter_test.dart';
import 'package:win_explorer/services/win32_drive_service.dart';
import 'package:win_explorer/entities/app_directory.dart';
import 'package:win_explorer/entities/app_file_system_entity.dart';
import 'package:win_explorer/entities/drive.dart';

void main() {
  test("1", () async {
    List<Drive> drives = Win32DriveService().getSystemDrives();
    Drive driveC = drives[0];
    AppDirectory directory1 = AppDirectory(path: driveC.mountPoint);
    List<AppFileSystemEntity> entities = await directory1.listAppEntities();
    for (AppFileSystemEntity entity in entities) {
      print(entity.name + " " + (await entity.type).toString());
    }
    List<AppDirectory> subdirectories = await directory1.getSubdirectories();
    for (AppDirectory directory in subdirectories) {
      print(directory.name);
    }
    Drive driveG = drives[1];
  });

  test("2", () async {
    List<Drive> drives = Win32DriveService().getSystemDrives();
    Drive driveC = drives[0];
    AppDirectory directory1 = AppDirectory(path: driveC.mountPoint);
    List<AppDirectory> subdirectories = await directory1.getSubdirectories();
    for (AppDirectory directory in subdirectories) {
      print(directory.name + " " + (await directory.modifiedTime).toString());
    }
    Drive driveG = drives[1];
  });
}
