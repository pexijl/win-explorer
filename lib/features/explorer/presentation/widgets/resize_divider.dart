import 'package:flutter/material.dart';

/// 封装的拖拽条组件
class ResizeDivider extends StatefulWidget {
  final double left;
  final ValueChanged<double> onDrag;
  final ValueChanged<MouseCursor> onCursorChange;

  const ResizeDivider({
    super.key,
    required this.left,
    required this.onDrag,
    required this.onCursorChange,
  });

  @override
  State<ResizeDivider> createState() => _ResizeDividerState();
}

class _ResizeDividerState extends State<ResizeDivider> {
  bool _isHovering = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      width: 10,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          widget.onDrag(details.delta.dx);
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
            if (!_isHovering) {
              widget.onCursorChange(SystemMouseCursors.basic);
            }
          });
        },
        onPanCancel: () {
          setState(() {
            _isDragging = false;
            if (!_isHovering) {
              widget.onCursorChange(SystemMouseCursors.basic);
            }
          });
        },
        child: MouseRegion(
          onEnter: (event) {
            setState(() {
              _isHovering = true;
              widget.onCursorChange(SystemMouseCursors.resizeColumn);
            });
          },
          onExit: (event) {
            setState(() {
              _isHovering = false;
              // 只有在非拖拽状态下，离开区域才恢复光标
              if (!_isDragging) {
                widget.onCursorChange(SystemMouseCursors.basic);
              }
            });
          },
          // child: Container(
          //   color: (_isHovering || _isDragging)
          //       ? Color.fromRGBO(255, 0, 0, 0.8)
          //       : Color.fromRGBO(0, 0, 255, 0.5),
          // ),
        ),
      ),
    );
  }
}
