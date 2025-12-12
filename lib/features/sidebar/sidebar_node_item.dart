import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

class SidebarNodeItem extends StatefulWidget {
  /// 节点数据
  final SidebarTreeNode node;

  /// 选中节点的Key
  final String? path;

  /// 点击展开/折叠回调函数
  final void Function(SidebarTreeNode) onToggleNode;

  /// 点击文件夹回调函数
  final void Function(AppDirectory) onSelectNode;

  const SidebarNodeItem({
    super.key,
    required this.node,
    required this.path,
    required this.onToggleNode,
    required this.onSelectNode,
  });

  @override
  State<SidebarNodeItem> createState() => _SidebarNodeItemState();
}

class _SidebarNodeItemState extends State<SidebarNodeItem> {
  /// 鼠标悬停
  bool _isHovered = false;

  static const _animationDuration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelectNode(widget.node.data);
      },
      child: Container(
        padding: EdgeInsets.only(right: 14),
        height: 40,
        decoration: BoxDecoration(color: Colors.white),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (event) => setState(() => _isHovered = true),
          onExit: (event) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: _isHovered
                  ? Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.5)
                  : (widget.node.data.path == widget.path
                      ? Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withValues(alpha: 0.8)
                      : null),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 8.0 + widget.node.level * 16.0,
                    right: 8.0,
                  ),
                  child: widget.node.hasChildren
                      ? IconButton(
                          icon: AnimatedRotation(
                            turns: widget.node.isExpanded ? 0.25 : 0.0,
                            duration: _animationDuration,
                            curve: Curves.easeInOut,
                            child: Icon(
                              Icons.chevron_right,
                              size: 24,
                            ),
                          ),
                          onPressed: () {
                            widget.onToggleNode(widget.node);
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        )
                      : SizedBox(width: 24),
                ),
                Icon(
                  widget.node.data.name == '此电脑'
                      ? Icons.computer
                      : Icons.folder,
                  color: widget.node.data.name == '此电脑'
                      ? Colors.blueGrey
                      : Colors.amber,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 0),
                      blurRadius: 1,
                    ),
                  ],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.node.data.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: widget.node.data.path == widget.path
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: widget.node.data.path == widget.path
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
