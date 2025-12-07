import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win_explorer/features/mainContent/folder_grid_item.dart';

class FolderGridView extends StatefulWidget {
  final List<FileSystemEntity> entities;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final Function(FileSystemEntity)? onItemTap;
  final Function(FileSystemEntity)? onItemDoubleTap;
  final Function(FileSystemEntity, TapDownDetails)? onItemSecondaryTapDown;

  const FolderGridView({
    super.key,
    required this.entities,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.onItemTap,
    this.onItemDoubleTap,
    this.onItemSecondaryTapDown,
  });

  @override
  State<FolderGridView> createState() => _FolderGridViewState();
}

class _FolderGridViewState extends State<FolderGridView> {
  String? _selectedFolder;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisExtent: 150,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
            childAspectRatio: 1,
          ),
          itemCount: widget.entities.length,
          itemBuilder: (context, index) {
            final entity = widget.entities[index];
            final isDir = entity is Directory;
            final name = entity.path.split(Platform.pathSeparator).last;
            return FolderGridItem(
              name: name,
              icon: isDir ? Icons.folder : Icons.insert_drive_file,
              isSelected: _selectedFolder == name,
              onTap: (folderName) {
                _selectedFolder = folderName;
                setState(() {});
              },
              onDoubleTap: () {
                widget.onItemDoubleTap?.call(entity);
              },
              onSecondaryTapDown: widget.onItemSecondaryTapDown != null
                  ? (details) => widget.onItemSecondaryTapDown!(entity, details)
                  : null,
            );
          },
        );
      },
    );
  }
}
