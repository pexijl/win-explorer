import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';
import 'package:win_explorer/features/mainContent/file_system_entity_list_item.dart';

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

  Widget _listHeader() {
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
                value: widget.selectedPaths.length == widget.entities.length
                    ? true
                    : widget.selectedPaths.isEmpty
                    ? false
                    : null,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      widget.selectedPaths.addAll(
                        widget.entities.map((e) => e.path),
                      );
                    } else {
                      widget.selectedPaths.clear();
                    }
                  });
                },
              ),
            ),
            SizedBox(width: 38),
            Container(
              width: _nameColumnWidth,
              height: 24,
              margin: const EdgeInsets.only(right: 16.0),
              alignment: Alignment.centerLeft,
              child: const Text('名称', style: TextStyle(color: Colors.black)),
            ),
            Container(
              width: _dateColumnWidth,
              height: 24,
              margin: const EdgeInsets.only(right: 16.0),
              alignment: Alignment.centerLeft,
              child: const Text('修改日期'),
            ),
            Container(
              width: _typeColumnWidth,
              height: 24,
              margin: const EdgeInsets.only(right: 16.0),
              alignment: Alignment.centerLeft,
              child: const Text('类型'),
            ),
            Container(
              width: _sizeColumnWidth,
              height: 24,
              alignment: Alignment.centerLeft,
              child: const Text('大小'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return GestureDetector(
      onTap: () {
        // 点击空白处取消所有选中
        setState(() {
          // TODO: 添加一个回调函数，通知父组件取消选择
          widget.selectedPaths.clear();
        });
      },
      child: ListView.builder(
        itemCount: widget.entities.length,
        itemBuilder: (context, index) {
          final entity = widget.entities[index];
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
