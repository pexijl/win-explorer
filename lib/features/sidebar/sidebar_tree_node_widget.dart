import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

class SidebarTreeNodeWidget extends StatefulWidget {
  final SidebarTreeNode node;
  final VoidCallback? onTap; // 新增参数
  const SidebarTreeNodeWidget({super.key, required this.node, this.onTap});

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
            color: widget.node.isSelected
                ? Colors.blueAccent.withOpacity(0.5)
                : widget.node.isHovered
                ? Colors.grey.withOpacity(0.3)
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
                onPressed: () {
                  setState(() {});
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
