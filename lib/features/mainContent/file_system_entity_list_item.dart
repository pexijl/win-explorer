import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';

class FileSystemEntityListItem extends StatefulWidget {
  final double nameColumnWidth;
  final double dateColumnWidth;
  final double typeColumnWidth;
  final double sizeColumnWidth;
  final AppFileSystemEntity entity;
  final Function(String?)? onTap;
  final VoidCallback? onDoubleTap;
  final Function(TapDownDetails)? onSecondaryTapDown;
  final bool isSelected;

  const FileSystemEntityListItem({
    super.key,
    this.nameColumnWidth = 300,
    this.dateColumnWidth = 150,
    this.typeColumnWidth = 150,
    this.sizeColumnWidth = 150,
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

  /// 双击检测变量
  int _lastTap = 0;
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          // 更灵敏的双击检测，顺便处理单击事件
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
          // 右键菜单
          onSecondaryTapDown: widget.onSecondaryTapDown,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
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
                  // 复选框
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: widget.isSelected,
                      splashRadius: 14,
                      onChanged: (value) {
                        widget.onTap?.call(widget.entity.path);
                      },
                    ),
                  ),
                  // 图标
                  Container(
                    width: 30,
                    margin: const EdgeInsets.only(right: 8.0),
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
                  // 名称
                  Container(
                    width: widget.nameColumnWidth,
                    height: 24,
                    margin: const EdgeInsets.only(right: 16.0),
                    alignment: Alignment.centerLeft,
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
                  // 时间
                  Container(
                    width: widget.dateColumnWidth,
                    height: 24,
                    margin: const EdgeInsets.only(right: 16.0),
                    alignment: Alignment.centerLeft,
                    // 异步获取修改时间
                    child: FutureBuilder<String>(
                      future: widget.entity.getFormattedModifiedTime(),
                      builder: (context, snapshot) {
                        return Text(snapshot.data ?? '');
                      },
                    ),
                  ),
                  // 类型
                  Container(
                    width: widget.typeColumnWidth,
                    height: 24,
                    margin: const EdgeInsets.only(right: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Text(widget.entity.typeName),
                  ),
                  // 大小
                  Container(
                    width: widget.sizeColumnWidth,
                    height: 24,
                    alignment: Alignment.centerLeft,
                    // 异步获取文件大小
                    child: FutureBuilder<String>(
                      future: widget.entity.getFormattedFileSize(),
                      builder: (context, snapshot) {
                        return Text(snapshot.data ?? '');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
