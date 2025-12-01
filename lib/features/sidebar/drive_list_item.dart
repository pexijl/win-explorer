import 'package:flutter/material.dart';
import 'package:win_explorer/domain/entities/drive.dart';

class DriveListItem extends StatelessWidget {
  final Drive drive;
  final int level;
  final bool isExpandable;
  final VoidCallback onTap;
  final VoidCallback? onExpanded;

  const DriveListItem({
    super.key,
    required this.drive,
    required this.level,
    required this.isExpandable,
    required this.onTap,
    this.onExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: drive.isSelected 
          ? Colors.grey[700]!.withOpacity(0.3)
          : Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0 + (level * 16.0), // 缩进层级
              top: 8,
              bottom: 8,
              right: 8,
            ),
            child: Row(
              children: [
                // 展开/折叠箭头
                if (isExpandable) ...[
                  IconButton(
                    icon: Icon(
                      drive.isExpanded
                          ? Icons.expand_more
                          : Icons.chevron_right,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    onPressed: onExpanded,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                ] else ...[
                  const SizedBox(width: 28), //位对齐
                ],
                
                // 图标
                _buildDriveIcon(drive),
                const SizedBox(width: 8),
                
                // 名称和空间信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drive.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (drive.type != 'computer' && drive.type != 'network') ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatSpaceInfo(drive),
                          style: TextStyle(
                            color: Colors.grey[500],
                            11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // 状态指示器
                if (drive.name == '百度网盘同步空间') ...[
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.green,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriveIcon(Drive drive) {
    final iconData = _getDriveIcon(drive.type);
    final color = _getDriveIconColor(drive.type);
    
    return Icon(
      iconData,
      size: 18,
      color: color,
    );
  }

  IconData _getDriveIcon(String type) {
    switch (type) {
      case 'computer':
        return Icons.computer;
      case 'fixed':
        return Icons.storage;
      case 'removable':
        return Icons.usb;
      case 'network':
        return Icons.cloud;
      case 'baidu-netdisk':
        return Icons.cloud_sync;
      default:
        return Icons.folder;
    }
  }

  Color _getDriveIconColor(String type) {
    switch (type) {
      case 'computer':
        return Colors.blue[300]!;
      case 'fixed':
        return Colors.green[300]!;
      case 'removable':
        return Colors.orange[300]!;
      case 'network':
        return Colors.purple[300]!;
      case 'baidu-netdisk':
        return Colors.blue[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  String _formatSpaceInfo(Drive drive) {
    if (drive.totalSpace == 0) return '';
    
    final freeGB = (drive.freeSpace / (1024 * 1024 * 1024)).toStringAsFixed(1);
    final totalGB = (drive.totalSpace / (1024 * 1024 * 1024)).toStringAsFixed(1);
    final usedPercent = ((drive.totalSpace - drive.freeSpace) / drive.totalSpace * 100).toStringAsFixed(0);
    
    return '$freeGB GB 可用，共 $totalGB GB ($usedPercent% 已使用)';
  }
}