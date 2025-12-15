import 'package:flutter/material.dart';
import 'package:win_explorer/utils/utils.dart';
import 'package:win_explorer/entities/app_file_system_entity.dart';

/// 文件/目录属性对话框
class EntityPropertyDialog extends StatelessWidget {
  final AppFileSystemEntity entity;

  const EntityPropertyDialog({
    super.key,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${entity.name}  属性'),
      content: FutureBuilder<EntityStats>(
        future: entity.getStats(),
        builder: (BuildContext context, AsyncSnapshot<EntityStats> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('错误: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final stats = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('类型: ${stats.type}'),
                Text('位置: ${stats.path}'),
                Text(
                  '大小: ${Utils.formatBytes(stats.size)} (${stats.size}) 字节',
                ),
                Text('创建时间: ${stats.createdTime}'),
                Text('修改时间: ${stats.modifiedTime}'),
                if (entity.isDirectory)
                  Text(
                    '包含: ${stats.fileCount} 文件, ${stats.directoryCount} 文件夹',
                  ),
              ],
            );
          } else {
            return const Text('无法获取文件属性');
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('关闭'),
        ),
      ],
    );
  }
}