import 'package:flutter/material.dart';
import 'package:win_explorer/entities/app_directory.dart';
import 'package:win_explorer/entities/app_file_system_entity.dart';
import 'package:win_explorer/entities/clipboard_manager.dart';

/// 右键菜单动作枚举
enum ContextMenuAction {
  /// 打开
  open,

  /// 属性
  properties,

  /// 剪切
  cut,

  /// 复制
  copy,

  /// 粘贴
  paste,

  /// 重命名
  rename,

  /// 删除
  delete,

  /// 新建文件夹
  newDirectory,

  /// 新建文件
  newFile,

  /// 刷新
  refresh,
}

/// 文件系统右键菜单
class FileSystemContextMenu {
  /// 为当前文件系统实体显示菜单
  ///
  /// [context] 上下文
  /// [position] 菜单位置
  /// [entity] 文件系统实体
  /// [onAction] 动作回调
  static void showForEntity({
    required BuildContext context,
    required Offset position,
    required AppFileSystemEntity entity,
    Function(ContextMenuAction action)? onAction,
  }) {
    showMenu<ContextMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(value: ContextMenuAction.open, child: const Text('打开')),
        PopupMenuItem(
          value: ContextMenuAction.properties,
          child: const Text('属性'),
        ),
        PopupMenuItem(value: ContextMenuAction.copy, child: const Text('复制')),
        PopupMenuItem(value: ContextMenuAction.cut, child: const Text('剪切')),
        PopupMenuItem(value: ContextMenuAction.paste, child: const Text('粘贴')),
        PopupMenuItem(
          value: ContextMenuAction.rename,
          child: const Text('重命名'),
        ),
        PopupMenuItem(value: ContextMenuAction.delete, child: const Text('删除')),
      ],
    ).then((value) {
      if (value != null) {
        onAction?.call(value);
      }
    });
  }

  /// 为目录显示上下文菜单（右键空白区域）
  ///
  /// [context] 上下文
  /// [position] 菜单位置
  /// [directory] 目录
  /// [onAction] 动作回调
  static void showForDirectory({
    required BuildContext context,
    required Offset position,
    required AppDirectory directory,
    Function(ContextMenuAction action)? onAction,
  }) {
    showMenu<ContextMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          value: ContextMenuAction.newDirectory,
          child: const Text('新建文件夹'),
        ),
        PopupMenuItem(
          value: ContextMenuAction.newFile,
          child: const Text('新建文件'),
        ),
        PopupMenuItem(
          value: ContextMenuAction.refresh,
          child: const Text('刷新'),
        ),
        if (ClipboardManager().hasItems)
          PopupMenuItem(
            value: ContextMenuAction.paste,
            child: Text(ClipboardManager().isCutMode ? '移动到此处' : '粘贴'),
          ),
        PopupMenuItem(
          value: ContextMenuAction.properties,
          child: const Text('属性'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        onAction?.call(value);
      }
    });
  }
}
