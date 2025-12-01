import 'package:flutter/material.dart';
import 'package:win_explorer/core/constants/global_constants.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/shared/widgets/resize_divider.dart';
import 'package:win_explorer/features/headerBar/index.dart';
import 'package:win_explorer/features/mainContent/index.dart';
import 'package:win_explorer/features/sidebar/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _sliderWidth = GlobalConstants.sliderMinWidth;
  double get screenWidth => MediaQuery.sizeOf(context).width;
  double get screenHeight => MediaQuery.sizeOf(context).height;
  MouseCursor _currentCursor = SystemMouseCursors.basic;
  
  AppDirectory? _currentDirectory;
  final List<AppDirectory> _history = [];
  int _historyIndex = -1;

  void _navigateTo(AppDirectory directory) {
    if (_currentDirectory?.path == directory.path) return;

    setState(() {
      // If we are in the middle of history and navigate to a new place,
      // we truncate the forward history.
      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }
      _history.add(directory);
      _historyIndex = _history.length - 1;
      _currentDirectory = directory;
    });
  }

  void _goBack() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _currentDirectory = _history[_historyIndex];
      });
    }
  }

  void _goForward() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _currentDirectory = _history[_historyIndex];
      });
    }
  }

  void _goUp() {
    if (_currentDirectory != null) {
      final parent = _currentDirectory!.parent;
      if (parent.path != _currentDirectory!.path) {
         _navigateTo(parent);
      }
    }
  }

  void _handlePathChanged(String path) {
    _navigateTo(AppDirectory(path));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MouseRegion(
          cursor: _currentCursor,
          child: Flex(
            direction: Axis.vertical,
            children: [
              HeaderBar(
                currentDirectory: _currentDirectory,
                onPathChanged: _handlePathChanged,
                onBack: _goBack,
                onForward: _goForward,
                onUp: _goUp,
                onRefresh: () {
                  setState(() {}); // Trigger rebuild to refresh
                },
                canGoBack: _historyIndex > 0,
                canGoForward: _historyIndex < _history.length - 1,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Sidebar(
                      left: 0,
                      right: screenWidth - _sliderWidth,
                      top: 0,
                      bottom: 0,
                      onDirectorySelected: _navigateTo,
                    ),
                    MainContent(
                      left: _sliderWidth,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      directory: _currentDirectory,
                    ),
                    ResizeDivider(
                      left: _sliderWidth,
                      onDrag: (dx) {
                        setState(() {
                          _sliderWidth += dx;
                          _sliderWidth = _sliderWidth.clamp(
                            250.0,
                            screenWidth - 250.0,
                          );
                        });
                      },
                      onCursorChange: (cursor) {
                        setState(() {
                          _currentCursor = cursor;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
