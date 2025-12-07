import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/features/home/this_computer.dart';
import 'folder_grid_view.dart';

class MainContent extends StatefulWidget {
  final double _left;
  final double _right;
  final double _top;
  final double _bottom;
  final AppDirectory? directory;
  final Function(AppDirectory)? onDirectoryDoubleTap;

  const MainContent({
    super.key,
    required double left,
    required double right,
    required double top,
    required double bottom,
    this.directory,
    this.onDirectoryDoubleTap,
  }) : _left = left,
       _right = right,
       _top = top,
       _bottom = bottom;

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  List<FileSystemEntity> _entities = [];
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
      final entities = await widget.directory!.listEntities();
      if (mounted) {
        setState(() {
          _entities = entities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _entities = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget._left,
      right: widget._right,
      top: widget._top,
      bottom: widget._bottom,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: widget.directory == null
            ? const Center(child: Text('请选择一个文件夹'))
            : _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildGridView(),
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

    return FolderGridView(
      entities: _entities,
      onItemTap: (entity) {},
      onItemDoubleTap: (entity) {
        if (entity is Directory) {
          widget.onDirectoryDoubleTap?.call(
            AppDirectory.fromFileSystemEntity(entity),
          );
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
    FileSystemEntity entity,
  ) {
    final isDir = entity is Directory;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(child: Text(isDir ? '打开文件夹' : '打开文件'), value: 'open'),
        PopupMenuItem(child: Text('属性'), value: 'properties'),
      ],
    ).then((value) {
      if (value == 'open') {
        // TODO: Implement open action
      } else if (value == 'properties') {
        // TODO: Implement properties action
      }
    });
  }
}
