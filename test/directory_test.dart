import 'package:flutter_test/flutter_test.dart';
import 'package:win_explorer/data/services/win32_service.dart';
import 'package:win_explorer/domain/entities/directory.dart';
import 'package:win_explorer/domain/entities/file_system_entity%20.dart';







void main() {

  test("1", () async {
    List<String> drives = Win32Service().getDriveList();
    Directory dir = Directory(drives[0]);
    List<FileSystemEntity> results = await dir.listEntities();
    print(results);
  });

}
