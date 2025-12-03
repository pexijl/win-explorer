import 'package:flutter/material.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

/// 用于[SidebarTreeNode]的一个图块。
class SidebarTreeNodeTile extends StatefulWidget {
  /// 节点
  final SidebarTreeNode node;

  /// 选中的节点
  final SidebarTreeNode? selectedNode;

  /// 点击节点
  final Function(SidebarTreeNode) onNodeSelected;

  /// 节点改变回调
  final VoidCallback? onNodeChanged;

  const SidebarTreeNodeTile({
    super.key,
    required this.node,
    required this.selectedNode,
    required this.onNodeSelected,
    this.onNodeChanged,
  });

  @override
  State<SidebarTreeNodeTile> createState() => _SidebarTreeNodeTileState();
}

class _SidebarTreeNodeTileState extends State<SidebarTreeNodeTile> {
  /// 鼠标悬停
  bool _isHovered = false;

  /// 是否展开
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildNodeTile();
  }

  Widget _buildNodeTile() {
    final isSelected = widget.node == widget.selectedNode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onNodeSelected(widget.node),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.withOpacity(0.2)
                : _isHovered
                ? Colors.grey.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: widget.node.hasChildren
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        splashRadius: 12,
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.chevron_right,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                            if(_isExpanded){
                              widget.node.loadChildren();
                            }
                          });
                        },
                      )
                    : null,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.folder, size: 16, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.node.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
