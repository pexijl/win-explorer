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

  /// 点击文件夹回调函数
  final void Function(SidebarTreeNode) onSelectNode;

  /// 动画控制器
  final dynamic animation;

  const SidebarNodeItem({
    super.key,
    required this.node,
    required this.selectedNodeId,
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
    final SidebarTreeNode model = context.watch<SidebarTreeNode>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isSelected = widget.selectedNodeId == model.id;
    final bool showExpander = model.showExpander;
    final bool isPlaceholder = model.isPlaceholder;
    final double indent = model.depth * 14.0;

    final Color backgroundColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.15)
        : _isHovered
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
        : Colors.transparent;

    final Widget item = MouseRegion(
      cursor: isPlaceholder
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          splashColor: colorScheme.primary.withValues(alpha: 0.12),
          onTap: isPlaceholder ? null : () => widget.onSelectNode(model),
          // onDoubleTap: (!showExpander || isPlaceholder)
          //     ? null
          //     : () => widget.onToggleNode(widget.node),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: indent),
                _buildChevron(showExpander, model, colorScheme),
                const SizedBox(width: 4),
                _buildFolderIcon(model, colorScheme, isSelected),
                const SizedBox(width: 8),
                Expanded(
                  child: Tooltip(
                    message: model.appDirectory.path,
                    waitDuration: const Duration(milliseconds: 600),
                    child: Text(
                      model.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isPlaceholder
                            ? theme.disabledColor
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
                if (model.isLoadingChildren)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.animation != null && widget.animation is Animation<double>) {
      return FadeTransition(
        opacity: widget.animation,
        child: item,
      );
    } else {
      return item;
    }
  }

  Widget _buildChevron(
    bool showExpander,
    SidebarTreeNode model,
    ColorScheme colorScheme,
  ) {
    if (!showExpander) {
      return const SizedBox(width: 24, height: 24);
    }
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        padding: EdgeInsets.zero,
        splashRadius: 14,
        iconSize: 18,
        icon: AnimatedRotation(
          turns: model.isExpanded ? 0.25 : 0.0,
          duration: const Duration(milliseconds: 160),
          child: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ),
        onPressed: model.isPlaceholder
            ? null
            : () => widget.onToggleNode(widget.node),
      ),
    );
  }

  Widget _buildFolderIcon(
    SidebarTreeNode model,
    ColorScheme colorScheme,
    bool isSelected,
  ) {
    IconData iconData;
    if (model.isPlaceholder) {
      iconData = Icons.pending;
    } else if (model.isExpanded && model.showExpander) {
      iconData = Icons.folder_open;
    } else {
      iconData = Icons.folder;
    }

    final Color iconColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withOpacity(
            model.isPlaceholder ? 0.6 : 0.9,
          );

    return Icon(iconData, size: 18, color: iconColor);
  }
}
