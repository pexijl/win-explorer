import 'package:flutter/material.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

class SidebarTreeNodeWidget extends StatefulWidget {
  final SidebarTreeNode node;
  final SidebarTreeNode? selectedNode;
  final Function(SidebarTreeNode) onNodeSelected;

  const SidebarTreeNodeWidget({
    super.key,
    required this.node,
    required this.selectedNode,
    required this.onNodeSelected,
  });

  @override
  State<SidebarTreeNodeWidget> createState() => _SidebarTreeNodeWidgetState();
}

class _SidebarTreeNodeWidgetState extends State<SidebarTreeNodeWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.node,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNodeTile(),
            if (widget.node.isExpanded) _buildChildren(),
          ],
        );
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
                        onPressed: () => widget.node.toggleExpanded(),
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

  Widget _buildChildren() {
    if (widget.node.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(left: 28.0, top: 4, bottom: 4),
        child: SizedBox(
          width: 12, 
          height: 12, 
          child: CircularProgressIndicator(strokeWidth: 2)
        ),
      );
    }

    final children = widget.node.children;
    if (children == null || children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((child) => SidebarTreeNodeWidget(
          node: child,
          selectedNode: widget.selectedNode,
          onNodeSelected: widget.onNodeSelected,
        )).toList(),
      ),
    );
  }
}
