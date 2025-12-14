import 'package:flutter/material.dart';
import 'package:win_explorer/core/constants/global_constants.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/features/bottomBar/index.dart';
import 'package:win_explorer/shared/widgets/resize_divider.dart';
import 'package:win_explorer/features/headerBar/index.dart';
import 'package:win_explorer/features/mainContent/index.dart';
import 'package:win_explorer/features/sidebar/index.dart';

/// 视图类型枚举
enum ViewType { grid, list, bank }

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
  int _currentEntityCount = 0;
  ViewType _currentViewType = ViewType.list;
  String _searchQuery = '';

  AppDirectory? _currentDirectory;
  final List<AppDirectory> _history = [];
  int _historyIndex = -1;

  final GlobalKey<MainContentState> _mainContentKey = GlobalKey();

  void _navigateTo(AppDirectory directory) {
    print('Navigating to ${directory}');
    if (_currentDirectory?.path == directory.path) return;

    setState(() {
      // 如果我们处于历史记录的中间并导航到一个新位置，
      // 我们会截断向前的历史记录。
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
    _navigateTo(AppDirectory(path: path));
  }

  void _handleSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
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
                height: 50,
                currentDirectory: _currentDirectory,
                onPathChanged: _handlePathChanged,
                searchQuery: _searchQuery,
                onSearchChanged: _handleSearchChanged,
                onBack: _goBack,
                onForward: _goForward,
                onUp: _goUp,
                onRefresh: () async {
                  await _mainContentKey.currentState?.refresh();
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
                      bottom: 30,
                      onDirectorySelected: _navigateTo,
                    ),
                    MainContent(
                      key: _mainContentKey,
                      left: _sliderWidth,
                      right: 0,
                      top: 0,
                      bottom: 30,
                      viewType: _currentViewType,
                      directory: _currentDirectory,
                      searchQuery: _searchQuery,
                      onDirectoryDoubleTap: _navigateTo,
                      onTotalEntitiesChanged: (total) {
                        setState(() => _currentEntityCount = total);
                      },
                    ),
                    ResizeDivider(
                      left: _sliderWidth,
                      bottom: 30,
                      onDrag: (dx) {
                        setState(() {
                          _sliderWidth += dx;
                          _sliderWidth = _sliderWidth.clamp(
                            100.0,
                            screenWidth - 150.0,
                          );
                        });
                      },
                      onCursorChange: (cursor) {
                        setState(() {
                          _currentCursor = cursor;
                        });
                      },
                    ),
                    BottomBar(
                      left: 0,
                      right: 0,
                      top: screenHeight - 80,
                      bottom: 0,
                      viewType: _currentViewType,
                      onViewTypeChanged: (newType) {
                        setState(() => _currentViewType = newType);
                      },
                      entityCount: _currentEntityCount,
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
