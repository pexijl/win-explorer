import 'package:flutter/material.dart';
import 'package:win_explorer/pages/main_page.dart';

class BottomBar extends StatefulWidget {
  final double left;
  final double right;
  final double top;
  final double bottom;
  final int entityCount;
  final ViewType viewType;
  final Function(ViewType)? onViewTypeChanged;

  const BottomBar({
    super.key,
    required this.entityCount,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.viewType,
    this.onViewTypeChanged,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      right: widget.right,
      top: widget.top,
      bottom: widget.bottom,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
        ),
        child: Row(
          children: [
            Text('${widget.entityCount} 个项目'),
            const Spacer(),
            Container(
              color: widget.viewType == ViewType.list
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.view_list),
                onPressed: () {
                  if (widget.viewType != ViewType.list) {
                    widget.onViewTypeChanged?.call(ViewType.list);
                  }
                },
                tooltip: '列表视图',
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: widget.viewType == ViewType.grid
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.view_module),
                onPressed: () {
                  if (widget.viewType != ViewType.grid) {
                    widget.onViewTypeChanged?.call(ViewType.grid);
                  }
                },
                tooltip: '网格视图',
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
