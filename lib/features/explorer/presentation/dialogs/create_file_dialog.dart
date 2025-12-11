import 'package:flutter/material.dart';

class CreateFileDialog extends StatefulWidget {
  final String initialName;
  final Function(String, String) onCreate;

  const CreateFileDialog({
    super.key,
    this.initialName = '新建文件',
    required this.onCreate,
  });

  @override
  State<CreateFileDialog> createState() => _CreateFileDialogState();
}

class _CreateFileDialogState extends State<CreateFileDialog> {
  late TextEditingController _controller;
  String? _errorText;
  String _selectedType = 'txt';

  static const List<String> fileTypes = [
    'txt',
    'dart',
    'md',
    'BMP',
    'zip',
    'word',
    'pptx',
    'xlsx',
  ];

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
      setState(() => _errorText = '文件名不能为空');
      return;
    }
    if (name.contains('/') ||
        name.contains('\\') ||
        name.contains('<') ||
        name.contains('>') ||
        name.contains(':') ||
        name.contains('"') ||
        name.contains('|') ||
        name.contains('?') ||
        name.contains('*') ||
        name.contains('.')) {
      setState(() => _errorText = '文件名包含非法字符');
      return;
    }
    widget.onCreate(name, _selectedType);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建文件'),
      content: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minWidth: 300),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: '文件名',
                  errorText: _errorText,
                ),
                onSubmitted: (_) => _validateAndCreate(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          DropdownMenu<String>(
            initialSelection: _selectedType,
            onSelected: (String? value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
            dropdownMenuEntries: fileTypes.map<DropdownMenuEntry<String>>((
              String type,
            ) {
              return DropdownMenuEntry<String>(value: type, label: '.$type');
            }).toList(),
            label: const Text('文件类型'),
          ),
        ],
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
