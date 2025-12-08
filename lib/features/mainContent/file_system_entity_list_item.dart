import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';

class FileSystemEntityListItem extends StatefulWidget {
  final AppFileSystemEntity entity;
  final Function(String)? onTap;
  final VoidCallback? onDoubleTap;
  final Function(TapDownDetails)? onSecondaryTapDown;
  final bool isSelected;

  const FileSystemEntityListItem({
    super.key,
    required this.entity,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapDown,
    this.isSelected = false,
  });

  @override
  State<FileSystemEntityListItem> createState() =>
      _FileSystemEntityListItemState();
}

class _FileSystemEntityListItemState extends State<FileSystemEntityListItem> {
  /// 鼠标悬停
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call(widget.entity.name);
      },
      onDoubleTap: widget.onDoubleTap,
      onSecondaryTapDown: widget.onSecondaryTapDown,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: _isHovered
                ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.5)
                : widget.isSelected == true
                ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.8)
                : null,
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 0),
                ),
                child: Icon(
                  widget.entity.icon,
                  color: widget.entity.iconColor,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 0),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
              Container(
                width: 300,
                height: 24,
                margin: const EdgeInsets.only(right: 16.0),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 0),
                ),
                child: Text(
                  widget.entity.name,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 150,
                height: 24,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 0),
                ),
                child: Text(widget.entity.getFormattedModifiedTime()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
