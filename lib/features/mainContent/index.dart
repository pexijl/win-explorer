import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';

class MainContent extends StatefulWidget {
  final double _left;
  final double _right;
  final double _top;
  final double _bottom;
  final AppDirectory? directory;

  const MainContent({
    super.key,
    required double left,
    required double right,
    required double top,
    required double bottom,
    this.directory,
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
    if (_entities.isEmpty) {
      return const Center(child: Text('文件夹为空'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _entities.length,
      itemBuilder: (context, index) {
        final entity = _entities[index];
        final isDir = entity is Directory;
        final name = entity.path.split(Platform.pathSeparator).last;

        return GestureDetector(
          onTap: () {
            // Handle selection
          },
          onDoubleTap: () {
            // Handle navigation if it's a directory
          },
          onSecondaryTapDown: (details) {
            _showContextMenu(context, details.globalPosition, entity);
          },
          child: Tooltip(
            message: name,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  isDir ? Icons.folder : Icons.insert_drive_file,
                  size: 48,
                  color: isDir ? Colors.amber : Colors.blueGrey,
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
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
