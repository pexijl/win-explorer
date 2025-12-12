import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';
import 'package:win_explorer/features/mainContent/file_system_entity_grid_item.dart';

class FileSystemGridView extends StatefulWidget {
  final List<AppFileSystemEntity> entities;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final Function(AppFileSystemEntity)? onItemTap;
  final Function(AppFileSystemEntity)? onItemDoubleTap;
  final Function(AppFileSystemEntity, TapDownDetails)? onItemSecondaryTapDown;

  const FileSystemGridView({
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
  State<FileSystemGridView> createState() => _FileSystemGridViewState();
}

class _FileSystemGridViewState extends State<FileSystemGridView> {
  String? _selectedItemName;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            _selectedItemName = null;
            setState(() {});
          },
          child: GridView.builder(
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
              return FileSystemEntityGridItem(
                entity: entity,
                iconColor: entity.iconColor,
                isSelected: _selectedItemName == entity.name,
                onTap: (itemName) {
                  _selectedItemName = itemName;
                  setState(() {});
                },
                onDoubleTap: () {
                  widget.onItemDoubleTap?.call(entity);
                },
                onSecondaryTapDown: widget.onItemSecondaryTapDown != null
                    ? (details) =>
                          widget.onItemSecondaryTapDown!(entity, details)
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}
