import 'package:flutter/material.dart';
import 'package:win_explorer/entities/app_file_system_entity.dart';

class DeleteDialog extends StatelessWidget {
  final AppFileSystemEntity entity;

  const DeleteDialog({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final isDirectory = entity.isDirectory;
    final typeText = isDirectory ? '文件夹' : '文件';

    return AlertDialog(
      title: const Text('确认删除'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('确定要删除以下$typeText吗？'),
          const SizedBox(height: 8),
          Text(
            '"${entity.name}"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (isDirectory) ...[
            const SizedBox(height: 8),
            const Text(
              '注意：删除文件夹将同时删除其所有内容。此操作无法撤销。',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              '此操作无法撤销。',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('删除'),
        ),
      ],
    );
  }
}