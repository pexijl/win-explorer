import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

class SidebarTreeNodeWidget extends StatefulWidget {
  /// 用于显示的节点
  final SidebarTreeNode node;

  /// 当前节点是否被选中
  final bool isSelected;

  /// 点击事件
  final VoidCallback? onTap;
  const SidebarTreeNodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<SidebarTreeNodeWidget> createState() => _SidebarTreeNodeWidgetState();
}

class _SidebarTreeNodeWidgetState extends State<SidebarTreeNodeWidget> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          widget.node.isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          widget.node.isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap ?? widget.node.onTap,
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.blueAccent.withValues(alpha: 0.5)
                : widget.node.isHovered
                ? Colors.grey.withValues(alpha: 0.3)
                : Colors.transparent,
            border: Border.all(color: Colors.redAccent),
          ),
          child: Row(
            children: [
              IconButton(
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                mouseCursor: SystemMouseCursors.basic,
                padding: EdgeInsets.zero,
                icon: Icon(
                  widget.node.isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.chevron_right,
                ),
                onPressed: () {
                  setState(() {
                    widget.node.isExpanded = !widget.node.isExpanded;
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  overlayColor: Colors.transparent,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                  textStyle: TextStyle(color: Colors.black),
                ),

                onPressed: () {
                  setState(() {
                    widget.onTap?.call();
                  });
                },
                child: Text(widget.node.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
