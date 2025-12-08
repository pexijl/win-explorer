import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';
import 'package:win_explorer/features/home/index.dart';
import 'package:win_explorer/features/home/this_computer.dart';
import 'file_system_grid_view.dart';
import 'file_system_list_view.dart';

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
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  List<AppFileSystemEntity> _entities = [];
  bool _isLoading = false;

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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: widget.directory == null
            ? const Center(child: Text('请选择一个文件夹'))
            : _isLoading
            ? const Center(child: CircularProgressIndicator())
            : widget.viewType == ViewType.grid ? _buildGridView() : _buildListView(),
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
        _showContextMenu(context, details.globalPosition, entity);
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
        _showContextMenu(context, details.globalPosition, entity);
      },
    );
  }

  void _showContextMenu(
    BuildContext context,
    Offset position,
    AppFileSystemEntity entity,
  ) {
    final isDir = entity is AppDirectory;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(value: 'open', child: Text(isDir ? '打开文件夹' : '打开文件')),
        PopupMenuItem(value: 'properties', child: Text('属性')),
      ],
    ).then((value) {
      if (value == 'open') {
        print('Open ${entity.path}');
      } else if (value == 'properties') {
        // TODO: Implement properties action
        print('Properties ${entity.path}');
      }
    });
  }
}
