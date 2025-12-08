import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';
import 'package:win_explorer/features/mainContent/file_system_entity_list_item.dart';

class FileSystemListView extends StatefulWidget {
  final List<AppFileSystemEntity> entities;
  final Function(AppFileSystemEntity)? onItemTap;
  final Function(AppFileSystemEntity)? onItemDoubleTap;
  final Function(AppFileSystemEntity, TapDownDetails)? onItemSecondaryTapDown;

  const FileSystemListView({
    super.key,
    required this.entities,
    this.onItemTap,
    this.onItemDoubleTap,
    this.onItemSecondaryTapDown,
  });

  @override
  State<FileSystemListView> createState() => _FileSystemListViewState();
}

class _FileSystemListViewState extends State<FileSystemListView> {
  String? _selectedItemName;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.entities.length,
      itemBuilder: (context, index) {
        final entity = widget.entities[index];
        return FileSystemEntityListItem(
          entity: entity,
          isSelected: _selectedItemName == entity.name,
          onTap: (itemName) {
            _selectedItemName = itemName;
            setState(() {});
          },
          onDoubleTap: () => widget.onItemDoubleTap?.call(entity),
          onSecondaryTapDown: (details) =>
              widget.onItemSecondaryTapDown?.call(entity, details),
        );
      },
    );
  }
}
