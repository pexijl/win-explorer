import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:win_explorer/features/sidebar/sidebar_tree_node.dart';

class SidebarTreeNodeWidget extends StatefulWidget {
  final SidebarTreeNode node;
  final bool isSelected;
  final VoidCallback? onTap;
  final Function(SidebarTreeNode)? onNodeSelected; // 新增：节点选中回调

  const SidebarTreeNodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    this.onTap,
    this.onNodeSelected,
  });

  @override
  State<SidebarTreeNodeWidget> createState() => _SidebarTreeNodeWidgetState();
}

class _SidebarTreeNodeWidgetState extends State<SidebarTreeNodeWidget> {
  late Future<void> _loadChildrenFuture;
  SidebarTreeNode? _selectedNode; // 添加选中节点状态

  @override
  void initState() {
    super.initState();
    // 在初始化阶段预加载是否有子节点的信息
    if (!widget.node.hasChildren) {
      widget.node.getChildren().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }

    // 初始化子节点加载 Future
    _loadChildrenFuture = widget.node.getChildren();
  }

  // 添加处理节点选中的方法
  void _handleNodeSelected(SidebarTreeNode selectedNode) {
    setState(() {
      _selectedNode = selectedNode;
    });
    // 向上传递选中事件
    if (widget.onNodeSelected != null) {
      widget.onNodeSelected!(selectedNode);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        onTap: () {
          // 调用原始的 onTap 回调
          if (widget.onTap != null) {
            widget.onTap!();
          }
          // 通知父组件当前节点被选中
          if (widget.onNodeSelected != null) {
            widget.onNodeSelected!(widget.node);
          }
        },
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
              if (widget.node.hasChildren)
                SizedBox(
                  width: 30,
                  child: IconButton(
                    highlightColor: Colors.transparent,
                    mouseCursor: SystemMouseCursors.basic,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      widget.node.isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.chevron_right,
                    ),
                    onPressed: () async {
                      // 先切换状态
                      await widget.node.toggleExpanded();

                      // 然后更新UI
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                )
              else
                SizedBox(width: 30),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    overlayColor: Colors.transparent,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                    textStyle: const TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    // 调用原始的 onTap 回调
                    if (widget.onTap != null) {
                      widget.onTap!();
                    }
                    // 通知父组件当前节点被选中
                    if (widget.onNodeSelected != null) {
                      widget.onNodeSelected!(widget.node);
                    }
                  },
                  child: Text(
                    widget.node.name ?? '无效',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.node.hasChildren && widget.node.isExpanded) {
      return FutureBuilder(
        future: _loadChildrenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                currentNode,
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('加载中...'),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                currentNode,
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('加载失败'),
                ),
              ],
            );
          } else {
            List<Widget> childrenWidgets = [];
            for (var childNode in widget.node.children!) {
              childrenWidgets.add(
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: SidebarTreeNodeWidget(
                    node: childNode,
                    isSelected: _selectedNode == childNode, // 使用局部状态
                    onTap: () {
                      // 子节点点击事件处理
                    },
                    onNodeSelected: _handleNodeSelected, // 使用局部方法
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
        },
      );
    }

    return currentNode;
  }
}
