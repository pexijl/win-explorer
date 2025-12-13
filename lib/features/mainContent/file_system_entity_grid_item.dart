import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';

class FileSystemEntityGridItem extends StatefulWidget {
  final AppFileSystemEntity entity;
  final MaterialColor? iconColor;
  final Function(String?)? onTap;
  final VoidCallback? onDoubleTap;
  final Function(TapDownDetails)? onSecondaryTapDown;
  final Color? textColor;
  final bool? isSelected;

  const FileSystemEntityGridItem({
    super.key,
    required this.entity,
    this.iconColor = Colors.grey,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapDown,
    this.textColor,
    this.isSelected = false,
  });

  @override
  State<FileSystemEntityGridItem> createState() =>
      _FileSystemEntityGridItemState();
}

class _FileSystemEntityGridItemState extends State<FileSystemEntityGridItem> {
  /// 鼠标悬停
  bool _isHovered = false;

  /// 双击检测变量
  int _lastTap = 0;
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        int now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastTap < 300) {
          _tapCount++;
          if (_tapCount >= 2) {
            widget.onDoubleTap?.call();
            _tapCount = 0; // 重置计数
          }
        } else {
          _tapCount = 1;
          bool isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
          if (isCtrlPressed) {
            widget.onTap?.call(widget.entity.path);
          } else {
            widget.onTap?.call(null);
          }
        }
        _lastTap = now;
      },
      // onDoubleTap: widget.onDoubleTap,
      onSecondaryTapDown: widget.onSecondaryTapDown,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.entity.isImage)
                Image.file(
                  widget.entity.asAppFile!.file,
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.scaleDown,
                )
              else
                Icon(widget.entity.icon, size: 100.0, color: widget.iconColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  widget.entity.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color:
                        widget.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
