import 'package:flutter/material.dart';

class FolderItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Function(TapDownDetails)? onSecondaryTapDown;
  final Color? backgroundColor;
  final Color? textColor;

  const FolderItem({
    super.key,
    required this.name,
    this.icon = Icons.folder,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapDown,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTapDown: onSecondaryTapDown,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: backgroundColor ?? Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48.0,
                color: textColor ?? Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.0,
                color: textColor?.withOpacity(0.5) ?? Theme.of(context).iconTheme.color?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
