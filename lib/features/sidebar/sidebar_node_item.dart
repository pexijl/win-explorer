import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

class SidebarNodeItem extends StatefulWidget {
  /// 节点数据
  final TreeNode<AppDirectory> node;

  /// 选中节点的Key
  final String? selectedNodeKey;

  /// 点击展开/折叠回调函数
  final void Function(TreeNode<AppDirectory>) onToggleNode;

  /// 点击文件夹回调函数
  final void Function(String) onSelectNode;

  /// 动画控制器
  final dynamic animation;

  const SidebarNodeItem({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    required this.onToggleNode,
    required this.onSelectNode,
    this.animation,
  });

  @override
  State<SidebarNodeItem> createState() => _SidebarNodeItemState();
}

class _SidebarNodeItemState extends State<SidebarNodeItem> {
  /// 鼠标悬停
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.node.data == null) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () {
        if (widget.node.data != null) {
          widget.onSelectNode(widget.node.key);
        }
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          color: _isHovered
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) => setState(() => _isHovered = true),
            onExit: (event) => setState(() => _isHovered = false),
            child: Row(
              children: [
                Icon(Icons.folder),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.node.data!.name,
                    style: TextStyle(
                      fontWeight: widget.node.key == widget.selectedNodeKey
                          ? FontWeight.bold
                          : FontWeight.normal,
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
