import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';
import 'package:win_explorer/features/mainContent/file_system_entity_grid_item.dart';

class FileSystemGridView extends StatefulWidget {
  final List<AppFileSystemEntity> entities;
  final Set<String> selectedPaths;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final Function(AppFileSystemEntity)? onItemTap;
  final Function(AppFileSystemEntity)? onItemDoubleTap;
  final Function(AppFileSystemEntity, TapDownDetails)? onItemSecondaryTapDown;

  const FileSystemGridView({
    super.key,
    required this.entities,
    required this.selectedPaths,
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
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            // 点击空白处取消所有选择
            setState(() {
              // TODO: 添加一个回调函数，通知父组件取消选择
              widget.selectedPaths.clear();
            });
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
                isSelected: widget.selectedPaths.contains(entity.path),
                onTap: (itemPath) {
                  setState(() {
                    if (itemPath != null) {
                      // TODO: 添加一个回调函数 onSelectionChanged ，通知父组件选择

                      // 按住Ctrl键点击时，需要进行添加选中或删除选中
                      if (widget.selectedPaths.contains(itemPath)) {
                        widget.selectedPaths.remove(itemPath);
                      } else {
                        widget.selectedPaths.add(itemPath);
                      }
                    } else {
                      widget.selectedPaths.clear();
                      widget.selectedPaths.add(entity.path);
                    }
                  });
                },
                onDoubleTap: () {
                  widget.selectedPaths.clear();
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
