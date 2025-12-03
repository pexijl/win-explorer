import 'package:flutter/material.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

class SidebarTreeNodeTile extends StatefulWidget {
  final SidebarTreeNode node;
  final SidebarTreeNode? selectedNode;
  final Function(SidebarTreeNode) onNodeSelected;
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
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    widget.node.addListener(_handleNodeChange);
  }

  @override
  void didUpdateWidget(SidebarTreeNodeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.node != oldWidget.node) {
      oldWidget.node.removeListener(_handleNodeChange);
      widget.node.addListener(_handleNodeChange);
    }
  }

  @override
  void dispose() {
    widget.node.removeListener(_handleNodeChange);
    super.dispose();
  }

  void _handleNodeChange() {
    widget.onNodeChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.node,
      builder: (context, child) {
        return _buildNodeTile();
      },
    );
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
                          widget.node.isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.chevron_right,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          widget.node.toggleExpanded();
                        },
                      )
                    : null,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.folder, size: 16, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.node.name,
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
