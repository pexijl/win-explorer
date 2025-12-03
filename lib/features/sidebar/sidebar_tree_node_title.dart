import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

/// 用于[SidebarTreeNode]的一个图块。
class SidebarTreeNodeTile extends StatefulWidget {
  /// 节点
  final SidebarTreeNode node;

  /// 选中的节点
  final SidebarTreeNode? selectedNode;

  /// 点击节点
  final Function(SidebarTreeNode) onNodeSelected;

  /// 节点变化回调
  final VoidCallback? onNodeChanged;

  /// 是否展开
  final bool isExpanded;

  /// 展开状态改变
  final ValueChanged<bool>? onExpansionChanged;

  const SidebarTreeNodeTile({
    super.key,
    required this.node,
    required this.selectedNode,
    required this.onNodeSelected,
    this.isExpanded = false,
    this.onExpansionChanged,
    this.onNodeChanged,
  });

  @override
  State<SidebarTreeNodeTile> createState() => _SidebarTreeNodeTileState();
}

class _SidebarTreeNodeTileState extends State<SidebarTreeNodeTile> {
  /// 鼠标悬停
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildNodeTile();
  }

  /// 构建节点, 通过 [ChangeNotifierProvider] 包装, 以便监听节点变化
  Widget _buildNodeTile() {
    final isSelected = widget.node == widget.selectedNode;
    return ChangeNotifierProvider(
      create: (_) => widget.node,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => widget.onNodeSelected(widget.node),
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.2)
                  : _isHovered
                  ? Colors.grey.withValues(alpha: 0.1)
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
                            widget.isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.chevron_right,
                            color: Colors.grey[700],
                          ),
                          onPressed: () async {
                            // 切换展开状态（我们将新值发送到父组件）
                            final newExpanded = !widget.isExpanded;
                            print(
                              '子传父 newExpanded: $newExpanded (old=${widget.isExpanded})',
                            );
                            widget.onExpansionChanged?.call(newExpanded);
                            // 如果我们要切换到展开模式，请先加载子项。
                            if (newExpanded) {
                              try {
                                await widget.node.loadChildren();
                              } catch (e) {
                                // ignore or log error
                              }
                            }

                            // 通知父组件: 节点发生了变化（例如 children 已加载）
                            widget.onNodeChanged?.call();
                            print(
                              'node.id: ${widget.node.id} newExpanded: $newExpanded widget.isExpanded: ${widget.isExpanded} node.children: ${widget.node.children != null}',
                            );
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
      ),
    );
  }
}
