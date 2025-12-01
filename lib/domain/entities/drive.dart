import 'package:win_explorer/domain/entities/app_directory.dart';

/// 表示一个物理或逻辑驱动器（如 C:\, D:\）
class Drive {
  /// 驱动器的唯一标识符（例如："C:" 或 "PhysicalDrive0"）
  final String id;

  /// 驱动器的挂载点或根路径（例如 "C:\"）
  final String mountPoint;

  /// 驱动器的显示名称（例如 "系统盘" 或 "数据盘"）
  final String name;

  /// 驱动器的总容量（字节）
  final int totalSize;

  /// 驱动器的可用空间（字节）
  final int freeSpace;

  /// 驱动器类型（例如：固定磁盘、可移动磁盘、网络驱动器、CD-ROM）
  final DriveType type;

  /// 文件系统类型（例如：NTFS, FAT32, exFAT）
  final String fileSystem;

  /// 驱动器是否可读写（只读驱动器如 CD-ROM 为 false）
  final bool isWritable;

  /// 驱动器是否就绪可用（如光盘驱动器中无光盘则为 false）
  final bool isReady;

  /// 驱动器是否展开（用于 UI 展示状态）
  final bool isExpanded;

  /// 驱动器是否被选中（用于 UI 状态）
  final bool isSelected;

  /// 驱动器下的目录列表（可选）
  final List<AppDirectory> appDirectories;

  /// 创建一个驱动器实例
  Drive({
    required this.id,
    required this.mountPoint,
    required this.name,
    required this.totalSize,
    required this.freeSpace,
    required this.type,
    required this.fileSystem,
    required this.isWritable,
    required this.isReady,
    this.isExpanded = false,
    this.isSelected = false,
    this.appDirectories = const [],
  });

  /// 从 Map 数据（例如从平台通道或 JSON 解析）创建 Drive 实例的工厂构造函数
  factory Drive.fromMap(Map<String, dynamic> map) {
    return Drive(
      id: map['id'] ?? '',
      mountPoint: map['mountPoint'] ?? '',
      name: map['name'] ?? '本地磁盘',
      totalSize: map['totalSize'] ?? 0,
      freeSpace: map['freeSpace'] ?? 0,
      type: DriveType.values.firstWhere(
        (e) => e.toString() == 'DriveType.${map['type']}',
        orElse: () => DriveType.unknown,
      ),
      fileSystem: map['fileSystem'] ?? 'Unknown',
      isWritable: map['isWritable'] ?? true,
      isReady: map['isReady'] ?? true,
    );
  }

  /// 将 Drive 实例转换为 Map，便于序列化（如存储到数据库或转换为 JSON）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mountPoint': mountPoint,
      'name': name,
      'totalSize': totalSize,
      'freeSpace': freeSpace,
      'type': type.toString().split('.').last, // 存储枚举的字符串表示
      'fileSystem': fileSystem,
      'isWritable': isWritable,
      'isReady': isReady,
    };
  }

  /// 获取已用空间（字节）
  int get usedSpace => totalSize - freeSpace;

  /// 获取磁盘使用率（0.0 到 1.0 之间的小数）
  double get usageRatio => totalSize > 0 ? usedSpace / totalSize : 0.0;

  /// 获取磁盘使用率的百分比表示（字符串，如 "65.5%"）
  String get usagePercentage => '${(usageRatio * 100).toStringAsFixed(1)}%';

  /// 获取驱动器的盘符（例如，对于 mountPoint "C:\"，返回 "C"）
  String get driveLetter => mountPoint.substring(0, mountPoint.indexOf(':'));

  /// 获取一个简短的描述信息
  String get description {
    final sizeInGB = (totalSize / (1024 * 1024 * 1024)).toStringAsFixed(2);
    final freeInGB = (freeSpace / (1024 * 1024 * 1024)).toStringAsFixed(2);
    return '$name ($mountPoint) - 总空间: ${sizeInGB}GB, 可用: ${freeInGB}GB';
  }

  @override
  String toString() {
    return 'Drive{id: $id, mountPoint: $mountPoint, name: $name, '
        'totalSize: $totalSize, freeSpace: $freeSpace, type: $type, '
        'fileSystem: $fileSystem, isWritable: $isWritable, isReady: $isReady}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Drive && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 驱动器类型枚举
enum DriveType {
  unknown, // 未知类型
  fixed, // 本地固定磁盘（如系统盘 C:）
  removable, // 可移动磁盘（如 U 盘、移动硬盘）
  network, // 网络映射驱动器
  cdrom, // CD/DVD/BD 光驱
  ram, // RAM 磁盘
}
