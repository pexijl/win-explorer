import 'package:flutter/material.dart';
import 'package:win_explorer/data/services/win32_drive_service.dart';
import 'package:win_explorer/domain/entities/drive.dart';
import 'package:win_explorer/features/home/drive_item.dart';

class ThisComputer extends StatefulWidget {
  final void Function(Drive)? onItemDoubleTap;
  const ThisComputer({super.key, this.onItemDoubleTap});

  @override
  State<ThisComputer> createState() => _ThisComputerState();
}

class _ThisComputerState extends State<ThisComputer> {
  final List<Drive> drives = [];
  String _selectedDriveId = '';

  @override
  void initState() {
    super.initState();
    _getDrives();
  }

  void _getDrives() {
    drives.addAll(Win32DriveService().getSystemDrives());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 3,
          crossAxisSpacing: 8,
        ),
        itemCount: drives.length,
        itemBuilder: (context, index) {
          final drive = drives[index];
          return DriveItem(
            drive: drive,
            isSelected: _selectedDriveId == drive.id,
            onTap: (driveId) {
              _selectedDriveId = driveId;
              setState(() {});
            },
            onDoubleTap: () {
              widget.onItemDoubleTap?.call(drive);
            },
          );
        },
      ),
    );
  }
}
