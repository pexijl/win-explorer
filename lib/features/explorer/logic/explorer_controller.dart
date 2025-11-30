import 'dart:io';

import 'package:win_explorer/data/services/win32_service.dart';

class FileItemModel {
  final String path;
  final String displayName;
  final String typeDescription;
  
  FileItemModel(this.path, this.displayName, this.typeDescription);
}

class ExplorerController {
  final Win32Service _win32Service = Win32Service();

  // 将 dart:io 的 File 对象转换为包含 Windows 信息的模型
  FileItemModel processFile(FileSystemEntity file) {
    // 调用 Service
    final winInfo = _win32Service.getFileDetail(file.path);
    
    return FileItemModel(
      file.path,
      // 优先使用 Windows 返回的显示名称（可能隐藏了后缀），如果为空则用默认文件名
      winInfo.displayName.isNotEmpty ? winInfo.displayName : file.uri.pathSegments.last,
      winInfo.typeName,
    );
  }
}