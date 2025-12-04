import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

/// [SidebarTreeNode]的展示组件
class SidebarNodeItem extends StatefulWidget {
  /// TreeSliverNode 包装的节点
  final TreeSliverNode<SidebarTreeNode> node;

  /// 选中的节点的id
  final String? selectedNodeId;

  /// 点击展开/折叠回调函数
  final void Function(TreeSliverNode<SidebarTreeNode>) onToggleNode;

  const SidebarNodeItem({
    super.key,
    required this.node,
    required this.selectedNodeId,
    required this.onToggleNode,
  });

  @override
  State<SidebarNodeItem> createState() => _SidebarNodeItemState();
}

class _SidebarNodeItemState extends State<SidebarNodeItem> {
  /// 鼠标悬停
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          print('点击了节点: ${widget.node.content.label}');
        },
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.grey.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: widget.node.content.hasChildren
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        splashRadius: 12,
                        icon: Icon(
                          widget.node.isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.chevron_right,
                        ),
                        onPressed: () {
                          print('点击了展开/折叠按钮: ${widget.node.content.label}');
                          widget.onToggleNode(widget.node);
                        },
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  widget.node.content.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
