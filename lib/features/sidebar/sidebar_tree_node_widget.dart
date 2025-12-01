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
    // 构建当前节点的UI
    Widget currentNode = MouseRegion(
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
              // 显示展开/折叠图标（如果有子节点）
              if (widget.node.hasChildren)
                SizedBox(
                  width: 30,
                  child: IconButton(
                    // hoverColor: Colors.transparent,
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
                )
              else
                SizedBox(width: 30), // 占位符，保持对齐
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  overlayColor: Colors.transparent,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                  textStyle: TextStyle(color: Colors.black),
                ),
                onPressed: widget.onTap ?? widget.node.onTap,
                child: Text(widget.node.name),
              ),
            ],
          ),
        ),
      ),
    );

    // 如果有子节点且已展开，则递归显示子节点
    if (widget.node.hasChildren && widget.node.isExpanded) {
      List<Widget> childrenWidgets = [];

      for (var childNode in widget.node.children!) {
        childrenWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 20), // 缩进表示层级关系
            child: SidebarTreeNodeWidget(
              node: childNode,
              isSelected: false, // 这里应传递正确的选中状态
              onTap: () {
                // 处理子节点点击事件
              },
            ),
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [currentNode, ...childrenWidgets],
      );
    }

    return currentNode;
  }
}
