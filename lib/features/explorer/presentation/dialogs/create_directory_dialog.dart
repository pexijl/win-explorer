import 'package:flutter/material.dart';

class CreateDirectoryDialog extends StatefulWidget {
  final String initialName;
  final Function(String) onCreate;

  const CreateDirectoryDialog({
    super.key,
    this.initialName = '新建文件夹',
    required this.onCreate,
  });

  @override
  State<CreateDirectoryDialog> createState() => _CreateDirectoryDialogState();
}

class _CreateDirectoryDialogState extends State<CreateDirectoryDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndCreate() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = '文件夹名称不能为空');
      return;
    }
    // 可以添加更多验证，比如非法字符
    if (name.contains('/') ||
        name.contains('\\') ||
        name.contains('<') ||
        name.contains('>') ||
        name.contains(':') ||
        name.contains('"') ||
        name.contains('|') ||
        name.contains('?') ||
        name.contains('*')) {
      setState(() => _errorText = '文件夹名称包含非法字符');
      return;
    }
    widget.onCreate(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建文件夹'),
      content: Container(
        constraints: const BoxConstraints(minWidth: 300),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: '文件夹名称',
            border: const OutlineInputBorder(),
            errorText: _errorText,
          ),
          onSubmitted: (_) => _validateAndCreate(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _validateAndCreate, child: const Text('确定')),
      ],
    );
  }
}
