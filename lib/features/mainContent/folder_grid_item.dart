import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class FolderGridItem extends StatefulWidget {
  final String name;
  final IconData icon;
  final Function(String)? onTap;
  final VoidCallback? onDoubleTap;
  final Function(TapDownDetails)? onSecondaryTapDown;
  final Color? textColor;
  final bool? isSelected;

  const FolderGridItem({
    super.key,
    required this.name,
    this.icon = Icons.folder,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapDown,
    this.textColor,
    this.isSelected = false,
  });

  @override
  State<FolderGridItem> createState() => _FolderGridItemState();
}

class _FolderGridItemState extends State<FolderGridItem> {
  /// 鼠标悬停
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call(widget.name);
      },
      onDoubleTap: widget.onDoubleTap,
      onSecondaryTapDown: widget.onSecondaryTapDown,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered
                ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.5)
                : widget.isSelected == true
                ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.8)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 100.0,
                color: widget.icon == Icons.folder ? Colors.amber : Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color:
                        widget.textColor ??
                        Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'FolderGridItem Preview')
Widget folderGridItemPreview() {
  return FolderGridItem(name: 'Folder Name');
}
