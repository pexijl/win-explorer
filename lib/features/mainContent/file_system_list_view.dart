import 'dart:io';

import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';
import 'package:win_explorer/features/mainContent/file_system_entity_list_item.dart';

enum _SortField { name, date, type, size }

class FileSystemListView extends StatefulWidget {
  final List<AppFileSystemEntity> entities;
  final Set<String> selectedPaths;
  final Function(AppFileSystemEntity)? onItemTap;
  final Function(AppFileSystemEntity)? onItemDoubleTap;
  final Function(AppFileSystemEntity, TapDownDetails)? onItemSecondaryTapDown;

  const FileSystemListView({
    super.key,
    required this.entities,
    required this.selectedPaths,
    this.onItemTap,
    this.onItemDoubleTap,
    this.onItemSecondaryTapDown,
  });

  @override
  State<FileSystemListView> createState() => _FileSystemListViewState();
}

class _FileSystemListViewState extends State<FileSystemListView> {
  final double _nameColumnWidth = 300;
  final double _dateColumnWidth = 150;
  final double _typeColumnWidth = 150;
  final double _sizeColumnWidth = 100;
  
  // 排序相关状态
  bool _sortAscending = true; // true: 升序, false: 降序
  _SortField _sortField = _SortField.name;
  List<AppFileSystemEntity>? _cachedSortedEntities;
  List<AppFileSystemEntity>? _lastEntities;
  bool? _lastSortAscending;
  _SortField? _lastSortField;
  final Map<String, FileStat> _statCache = {};

  FileStat _statFor(AppFileSystemEntity entity) {
    return _statCache.putIfAbsent(entity.path, () => entity.entity.statSync());
  }

  int _compareByName(AppFileSystemEntity a, AppFileSystemEntity b) {
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  int _compareByDate(AppFileSystemEntity a, AppFileSystemEntity b) {
    final aDate = _statFor(a).modified;
    final bDate = _statFor(b).modified;
    final comparison = aDate.compareTo(bDate);
    return comparison != 0 ? comparison : _compareByName(a, b);
  }

  int _compareByType(AppFileSystemEntity a, AppFileSystemEntity b) {
    final comparison = a.typeName.compareTo(b.typeName);
    return comparison != 0 ? comparison : _compareByName(a, b);
  }

  int _compareBySize(AppFileSystemEntity a, AppFileSystemEntity b) {
    // 文件夹优先已在外层处理，这里只比较同类型或文件
    if (a.isDirectory && b.isDirectory) return _compareByName(a, b);
    if (a.isDirectory) return -1;
    if (b.isDirectory) return 1;

    final comparison = _statFor(a).size.compareTo(_statFor(b).size);
    return comparison != 0 ? comparison : _compareByName(a, b);
  }

  int _compareEntities(AppFileSystemEntity a, AppFileSystemEntity b) {
    // 文件夹始终在文件前面
    if (a.isDirectory && !b.isDirectory) return -1;
    if (!a.isDirectory && b.isDirectory) return 1;

    int comparison;
    switch (_sortField) {
      case _SortField.name:
        comparison = _compareByName(a, b);
        break;
      case _SortField.date:
        comparison = _compareByDate(a, b);
        break;
      case _SortField.type:
        comparison = _compareByType(a, b);
        break;
      case _SortField.size:
        comparison = _compareBySize(a, b);
        break;
    }

    return _sortAscending ? comparison : -comparison;
  }

  void _onSortFieldChanged(_SortField field) {
    setState(() {
      if (_sortField == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortField = field;
        _sortAscending = true;
      }
    });
  }

  Widget _buildHeaderButton(String label, double width, _SortField field) {
    final isActive = _sortField == field;
    final icon = isActive
        ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
        : Icons.unfold_more;
    final iconColor = isActive ? Colors.black87 : Colors.black45;

    return TextButton(
      onPressed: () => _onSortFieldChanged(field),
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        minimumSize: WidgetStateProperty.all(Size.zero),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
      child: Container(
        width: width,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 0),
        ),
        margin: const EdgeInsets.only(right: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.black)),
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: iconColor),
          ],
        ),
      ),
    );
  }

  /// 获取排序后的实体列表
  List<AppFileSystemEntity> get _sortedEntities {
    // 如果实体列表或排序顺序发生变化，重新排序
    if (_cachedSortedEntities == null ||
        _lastEntities != widget.entities ||
        _lastSortAscending != _sortAscending ||
        _lastSortField != _sortField) {
      if (_lastEntities != widget.entities) {
        _statCache.clear();
      }
      final List<AppFileSystemEntity> sorted = List.from(widget.entities);
      
      sorted.sort(_compareEntities);
      
      _cachedSortedEntities = sorted;
      _lastEntities = widget.entities;
      _lastSortAscending = _sortAscending;
      _lastSortField = _sortField;
    }
    
    return _cachedSortedEntities!;
  }

  Widget _listHeader() {
    final sortedEntities = _sortedEntities;
    
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 全选/取消 checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                splashRadius: 14,
                value: widget.selectedPaths.length == sortedEntities.length
                    ? true
                    : widget.selectedPaths.isEmpty
                    ? false
                    : null,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      widget.selectedPaths.addAll(
                        sortedEntities.map((e) => e.path),
                      );
                    } else {
                      widget.selectedPaths.clear();
                    }
                  });
                },
              ),
            ),
            SizedBox(width: 38),
            _buildHeaderButton('名称', _nameColumnWidth, _SortField.name),
            _buildHeaderButton('修改日期', _dateColumnWidth, _SortField.date),
            _buildHeaderButton('类型', _typeColumnWidth, _SortField.type),
            _buildHeaderButton('大小', _sizeColumnWidth, _SortField.size),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final sortedEntities = _sortedEntities;
    
    return GestureDetector(
      onTap: () {
        // 点击空白处取消所有选中
        setState(() {
          // TODO: 添加一个回调函数，通知父组件取消选择
          widget.selectedPaths.clear();
        });
      },
      child: ListView.builder(
        itemCount: sortedEntities.length,
        itemBuilder: (context, index) {
          final entity = sortedEntities[index];
          return FileSystemEntityListItem(
            nameColumnWidth: _nameColumnWidth,
            dateColumnWidth: _dateColumnWidth,
            typeColumnWidth: _typeColumnWidth,
            sizeColumnWidth: _sizeColumnWidth,
            entity: entity,
            isSelected: widget.selectedPaths.contains(entity.path),
            onTap: (itemPath) {
              if (itemPath != null) {
                // TODO: 添加一个回调函数 onSelectionChanged ，通知父组件选择

                // 点击复选框或按住Ctrl键点击时，需要进行添加选中或删除选中
                if (widget.selectedPaths.contains(itemPath)) {
                  widget.selectedPaths.remove(itemPath);
                } else {
                  widget.selectedPaths.add(itemPath);
                }
              } else {
                widget.selectedPaths.clear();
                widget.selectedPaths.add(entity.path);
              }
              setState(() {});
            },
            onDoubleTap: () {
              widget.selectedPaths.clear();
              widget.onItemDoubleTap?.call(entity);
            },
            onSecondaryTapDown: (details) {
              widget.onItemSecondaryTapDown?.call(entity, details);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _listHeader(),
        Expanded(child: _buildListView()),
      ],
    );
  }
}
