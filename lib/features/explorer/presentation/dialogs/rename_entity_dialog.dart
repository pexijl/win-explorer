import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/app_file_system_entity.dart';

class RenameEntityDialog extends StatefulWidget {
  final AppFileSystemEntity entity;

  const RenameEntityDialog({super.key, required this.entity});

  @override
  State<RenameEntityDialog> createState() => _RenameEntityDialogState();
}

class _RenameEntityDialogState extends State<RenameEntityDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entity.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndRename() {
    final newName = _controller.text.trim();
    if (newName.isEmpty) {
      setState(() => _errorText = '名称不能为空');
      return;
    }
    if (newName.contains('/') ||
        newName.contains('\\') ||
        newName.contains('<') ||
        newName.contains('>') ||
        newName.contains(':') ||
        newName.contains('"') ||
        newName.contains('|') ||
        newName.contains('?') ||
        newName.contains('*')) {
      setState(() => _errorText = '名称包含非法字符');
      return;
    }
    Navigator.of(context).pop(newName);
  }

  @override
  Widget build(BuildContext context) {
    final typeText = widget.entity.isDirectory ? '文件夹' : '文件';
    return AlertDialog(
      title: Text('重命名$typeText'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: '新名称',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _validateAndRename(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _validateAndRename, child: const Text('确定')),
      ],
    );
  }
}
