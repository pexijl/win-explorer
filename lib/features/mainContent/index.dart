import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_util;
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';
import 'package:win_explorer/domain/entities/clipboard_manager.dart';
import 'package:win_explorer/features/home/index.dart';
import 'package:win_explorer/features/home/this_computer.dart';
import 'package:win_explorer/features/explorer/presentation/dialogs/entity_property_dialog.dart';
import 'package:win_explorer/features/explorer/presentation/dialogs/create_directory_dialog.dart';
import 'package:win_explorer/features/explorer/presentation/dialogs/delete_dialog.dart';
import 'package:win_explorer/features/explorer/presentation/dialogs/create_file_dialog.dart';
import 'package:win_explorer/features/explorer/presentation/dialogs/rename_entity_dialog.dart';
import 'package:win_explorer/features/mainContent/file_system_context_menu.dart';
import 'package:win_explorer/features/mainContent/file_system_grid_view.dart';
import 'package:win_explorer/features/mainContent/file_system_list_view.dart';

class MainContent extends StatefulWidget {
  final double left;
  final double right;
  final double top;
  final double bottom;
  final ViewType viewType;
  final AppDirectory? directory;
  final Function(AppDirectory)? onDirectoryDoubleTap;
  final Function(int)? onTotalEntitiesChanged;

  const MainContent({
    super.key,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.viewType,
    this.directory,
    this.onDirectoryDoubleTap,
    this.onTotalEntitiesChanged,
  });

  @override
  State<MainContent> createState() => MainContentState();
}

class MainContentState extends State<MainContent> {
  List<AppFileSystemEntity> _entities = [];
  bool _isLoading = false;

  /// 刷新内容
  Future<void> refresh() async {
    await _loadContents();
  }

  @override
  void didUpdateWidget(MainContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.directory?.path != oldWidget.directory?.path) {
      _loadContents();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    if (widget.directory == null) {
      setState(() {
        _entities = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final entities = await widget.directory!.listAppEntities();
      if (mounted) {
        setState(() {
          _entities = entities;
          _isLoading = false;
        });
        // 加载完成后调用回调
        widget.onTotalEntitiesChanged?.call(entities.length);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _entities = [];
          _isLoading = false;
        });
        // 出错时传递0
        widget.onTotalEntitiesChanged?.call(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      right: widget.right,
      top: widget.top,
      bottom: widget.bottom,
      child: GestureDetector(
        onSecondaryTapDown: (details) {
          FileSystemContextMenu.showForDirectory(
            context: context,
            position: details.globalPosition,
            directory: widget.directory!,
            onAction: (action) async {
              switch (action) {
                case ContextMenuAction.newFile:
                  await _createFile();
                  break;
                case ContextMenuAction.newDirectory:
                  await _createDirectory();
                  break;
                case ContextMenuAction.refresh:
                  await refresh();
                  break;
                case ContextMenuAction.paste:
                  await _pasteEntities();
                  break;
                case ContextMenuAction.properties:
                  await _showProperties();
                  break;
                default:
                  break;
              }
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: widget.directory == null
              ? const Center(child: Text('请选择一个文件夹'))
              : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.viewType == ViewType.grid
              ? _buildGridView()
              : _buildListView(),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    if (widget.directory?.path == '此电脑') {
      return const ThisComputer();
    }

    if (_entities.isEmpty) {
      return const Center(child: Text('文件夹为空'));
    }

    return FileSystemGridView(
      entities: _entities,
      onItemTap: (entity) {},
      onItemDoubleTap: (entity) {
        if (entity.isDirectory) {
          widget.onDirectoryDoubleTap?.call(entity.asAppDirectory!);
        }
      },
      onItemSecondaryTapDown: (entity, details) {
        FileSystemContextMenu.showForEntity(
          context: context,
          position: details.globalPosition,
          entity: entity,
          onAction: (action) async {
            switch (action) {
              case ContextMenuAction.open:
                await _openEntity(entity);
                break;
              case ContextMenuAction.properties:
                await _showEntityProperties(entity);
                break;
              case ContextMenuAction.copy:
                await _copyEntity(entity);
                break;
              case ContextMenuAction.cut:
                await _cutEntity(entity);
                break;
              case ContextMenuAction.rename:
                await _renameEntity(entity);
                break;
              case ContextMenuAction.delete:
                await _deleteEntity(entity);
                break;
              default:
                break;
            }
          },
        );
      },
    );
  }

  Widget _buildListView() {
    if (widget.directory?.path == '此电脑') {
      return const ThisComputer();
    }

    if (_entities.isEmpty) {
      return const Center(child: Text('文件夹为空'));
    }

    return FileSystemListView(
      entities: _entities,
      onItemTap: (entity) {},
      onItemDoubleTap: (entity) {
        if (entity.isDirectory) {
          widget.onDirectoryDoubleTap?.call(entity.asAppDirectory!);
        }
      },
      onItemSecondaryTapDown: (entity, details) {
        FileSystemContextMenu.showForEntity(
          context: context,
          position: details.globalPosition,
          entity: entity,
          onAction: (action) async {
            switch (action) {
              case ContextMenuAction.open:
                await _openEntity(entity);
                break;
              case ContextMenuAction.properties:
                await _showEntityProperties(entity);
                break;
              case ContextMenuAction.copy:
                await _copyEntity(entity);
                break;
              case ContextMenuAction.cut:
                await _cutEntity(entity);
                break;
              case ContextMenuAction.rename:
                await _renameEntity(entity);
                break;
              case ContextMenuAction.delete:
                await _deleteEntity(entity);
                break;
              default:
                break;
            }
          },
        );
      },
    );
  }

  /// 打开文件
  Future<void> _openEntity(AppFileSystemEntity entity) async {
    if (entity.isDirectory) {
      widget.onDirectoryDoubleTap?.call(entity.asAppDirectory!);
    } else {
      Process.run('explorer', [entity.path]);
    }
  }

  /// 显示文件属性
  Future<void> _showEntityProperties(AppFileSystemEntity entity) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => EntityPropertyDialog(entity: entity),
    );
  }

  /// 复制文件
  Future<void> _copyEntity(AppFileSystemEntity entity) async {
    ClipboardManager().copy(entity);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: 300,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          content: Text('已复制 ${entity.name}'),
        ),
      );
    }
  }

  /// 剪切文件
  Future<void> _cutEntity(AppFileSystemEntity entity) async {
    ClipboardManager().cut(entity);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: 300,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          content: Text('已剪切 ${entity.name}'),
        ),
      );
    }
  }

  Future<void> _pasteEntities() async {
    if (widget.directory == null || !ClipboardManager().hasItems) return;

    try {
      await ClipboardManager().pasteTo(widget.directory!);
      await _loadContents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            width: 300,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            content: Text('粘贴完成'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            width: 300,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            content: Text('粘贴失败: $e'),
          ),
        );
      }
    }
  }

  /// 删除文件
  Future<void> _deleteEntity(AppFileSystemEntity entity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => DeleteDialog(entity: entity),
    );
    if (confirmed == true) {
      if (entity.isDirectory) {
        await entity.asAppDirectory!.deleteRecursively();
      } else {
        await entity.asAppFile!.delete();
      }
      await _loadContents();
    }
  }

  /// 重命名文件
  Future<void> _renameEntity(AppFileSystemEntity entity) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => RenameEntityDialog(entity: entity),
    );
    if (newName != null && newName.isNotEmpty && newName != entity.name) {
      try {
        final parentPath = path_util.dirname(entity.path);
        final newPath = '$parentPath${Platform.pathSeparator}$newName';
        await entity.rename(newPath);
        await _loadContents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              width: 300,
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              content: Text('重命名成功'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              width: 300,
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              content: Text('重命名失败: $e'),
            ),
          );
        }
      }
    }
  }

  /// 在资源管理器中显示文件
  Future<void> _showFileInExplorer(AppFileSystemEntity entity) async {
    if (entity.isDirectory) {
      widget.onDirectoryDoubleTap?.call(entity.asAppDirectory!);
    } else {
      Process.run('explorer', ['/select,', entity.path]);
    }
  }

  /// 创建文件
  Future<void> _createFile() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CreateFileDialog(
        onCreate: (name, extension) async {
          final fileName = '$name.$extension';
          final path =
              '${widget.directory!.path}${Platform.pathSeparator}$fileName';
          if (!await File(path).exists()) {
            await File(path).create(recursive: true);
          }
          await _loadContents();
        },
      ),
    );
  }

  /// 创建文件夹
  Future<void> _createDirectory() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CreateDirectoryDialog(
        onCreate: (name) async {
          await widget.directory!.createSubdirectory(name);
          await _loadContents();
        },
      ),
    );
  }

  /// 显示当前目录属性
  Future<void> _showProperties() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) =>
          EntityPropertyDialog(entity: widget.directory!.asAppEntity),
    );
  }
}
