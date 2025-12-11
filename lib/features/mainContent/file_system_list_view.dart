import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_directory.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';
import 'package:win_explorer/features/mainContent/file_system_entity_list_item.dart';

class FileSystemListView extends StatefulWidget {
  final List<AppFileSystemEntity> entities;
  final Function(AppFileSystemEntity)? onItemTap;
  final Function(AppFileSystemEntity)? onItemDoubleTap;
  final Function(AppFileSystemEntity, TapDownDetails)? onItemSecondaryTapDown;

  const FileSystemListView({
    super.key,
    required this.entities,
    this.onItemTap,
    this.onItemDoubleTap,
    this.onItemSecondaryTapDown,
  });

  @override
  State<FileSystemListView> createState() => _FileSystemListViewState();
}

class _FileSystemListViewState extends State<FileSystemListView> {
  String? _selectedItemName;
  final double _nameColumnWidth = 300;
  final double _dateColumnWidth = 150;
  final double _typeColumnWidth = 150;
  final double _sizeColumnWidth = 150;

  Widget _listHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 30, margin: const EdgeInsets.only(right: 8.0)),
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
        _selectedItemName = null;
        setState(() {});
      },
      // onSecondaryTapDown: (details) {
      //   // TODO: implement secondary tap
      // },
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
            isSelected: _selectedItemName == entity.name,
            onTap: (itemName) {
              _selectedItemName = itemName;
              setState(() {});
            },
            onDoubleTap: () => widget.onItemDoubleTap?.call(entity),
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
