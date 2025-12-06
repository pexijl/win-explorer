import 'dart:ffi';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final void Function(String) onSelectNode;

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

  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarTreeNode>(
      builder: (context, node, child) {
        return GestureDetector(
          onTap: () {
            print('节点：${node.hasChildren}');
            widget.onSelectNode(node.data.path);
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
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (event) => setState(() => _isHovered = true),
              onExit: (event) => setState(() => _isHovered = false),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8.0 + node.level * 16.0,
                      right: 8.0,
                    ),
                    child: node.hasChildren
                        ? IconButton(
                            icon: Icon(
                              node.isExpanded
                                  ? Icons.expand_more
                                  : Icons.chevron_right,
                              size: 24,
                            ),
                            onPressed: () {
                              print('切换 ${node.data.name}');
                              widget.onToggleNode(node);
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          )
                        : SizedBox(width: 24),
                  ),
                  Icon(Icons.folder),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.data.name,
                      style: TextStyle(
                        fontWeight: node.data.path == widget.path
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
        );
      },
    );
  }
}
