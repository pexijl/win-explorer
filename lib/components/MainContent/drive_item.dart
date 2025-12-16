import 'package:flutter/material.dart';
import 'package:win_explorer/entities/drive.dart';

class DriveItem extends StatefulWidget {
  final Drive drive;
  final Function(String)? onTap;
  final VoidCallback? onDoubleTap;
  final bool isSelected;
  const DriveItem({
    super.key,
    required this.drive,
    this.isSelected = false,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<DriveItem> createState() => _DriveItemState();
}

class _DriveItemState extends State<DriveItem> {
  bool _isHovered = false;

  /// 双击检测变量
  int _lastTap = 0;
  int _tapCount = 0;
  @override
  Widget build(BuildContext context) {
    double usedPercent =
        (widget.drive.totalSize - widget.drive.freeSpace) /
        widget.drive.totalSize;
    return GestureDetector(
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
          widget.onTap?.call(widget.drive.id);
        }
        _lastTap = now;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          padding: EdgeInsets.all(8),
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
                margin: EdgeInsets.only(right: 4),
                child: Icon(Icons.storage, size: 48, color: Colors.grey[600]),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(widget.drive.name),
                    LinearProgressIndicator(
                      value: usedPercent,
                      minHeight: 14,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '可用: ${widget.drive.getFormattedFreeSpace()}, 共 ${widget.drive.getFormattedTotalSize()}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
