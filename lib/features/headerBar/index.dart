import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';

class HeaderBar extends StatefulWidget {
  final double height;
  final AppDirectory? currentDirectory;
  final Function(String) onPathChanged;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onUp;
  final VoidCallback? onRefresh;
  final bool canGoBack;
  final bool canGoForward;

  const HeaderBar({
    super.key,
    required this.height,
    this.currentDirectory,
    required this.onPathChanged,
    this.onBack,
    this.onForward,
    this.onUp,
    this.onRefresh,
    this.canGoBack = false,
    this.canGoForward = false,
  });

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  late TextEditingController _pathController;
  final FocusNode _pathFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(
      text: widget.currentDirectory?.path ?? '',
    );
  }

  @override
  void didUpdateWidget(HeaderBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentDirectory?.path != oldWidget.currentDirectory?.path) {
      if (!_pathFocusNode.hasFocus) {
        _pathController.text = widget.currentDirectory?.path ?? '';
      }
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    _pathFocusNode.dispose();
    super.dispose();
  }

  void _handlePathSubmit(String value) {
    widget.onPathChanged(value);
    _pathFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Navigation Buttons
          _buildNavButton(Icons.arrow_back, widget.onBack, widget.canGoBack),
          _buildNavButton(
            Icons.arrow_forward,
            widget.onForward,
            widget.canGoForward,
          ),
          _buildNavButton(
            Icons.arrow_upward,
            widget.onUp,
            widget.currentDirectory != null,
          ),

          const SizedBox(width: 8),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: widget.onRefresh,
            splashRadius: 20,
            tooltip: '刷新',
          ),

          const SizedBox(width: 12),

          // Address Bar
          Expanded(
            flex: 3,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.folder_open,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _pathController,
                      focusNode: _pathFocusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 0),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                      onSubmitted: _handlePathSubmit,
                    ),
                  ),
                  if (widget.currentDirectory != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      onPressed: () => _handlePathSubmit(_pathController.text),
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Search Bar
          Expanded(
            flex: 1,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: '搜索',
                  prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 10), // Center vertically
                  isDense: true,
                ),
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback? onPressed, bool enabled) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: enabled ? onPressed : null,
      color: Colors.black87,
      disabledColor: Colors.grey[300],
      splashRadius: 20,
    );
  }
}
