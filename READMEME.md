# lib 目录结构

```
lib/
├── main.dart                  # 入口文件
├── app.dart                   # 应用入口 (初始化)
├── core/                      # 核心通用模块 (不包含具体业务逻辑)
│   ├── constants/             # 常量 (如尺寸、默认路径、API Key)
│   ├── theme/                 # 主题配置 (暗色/亮色模式，自定义颜色)
│   ├── utils/                 # 工具类 (文件大小格式化, 日期格式化, 防抖函数)
│   ├── errors/                # 错误处理与自定义异常
│   └── localization/          # 多语言支持 (l10n)
├── config/                    # 全局配置
│   ├── router/                # 路由定义 (GoRouter 或 AutoRoute)
│   └── shortcuts/             # 键盘快捷键定义 (Windows 必备)
├── data/                      # 数据层 (负责与系统交互)
│   ├── models/                # 数据模型 (FileEntity, FileStat, DriveInfo)
│   ├── repositories/          # 仓库接口 (抽象数据获取逻辑)
│   └── services/              # 具体服务实现
│       ├── file_system_service.dart # Dart:io 封装，基本文件操作
│       ├── win32_service.dart       # FFI 封装，调用 Windows 原生 API (如获取图标、磁盘信息)
│       └── preference_service.dart  # 本地存储 (SharedPreferences/Hive)
├── domain/                    # 领域层 (可选，如果不使用严格的 Clean Architecture 可省略)
│   └── entities/              # 纯粹的业务实体
├── features/                  # 功能模块 (按业务功能划分)
│   ├── home/                  # 主页/容器
│   ├── explorer/              # 核心资源管理功能
│   │   ├── presentation/      # UI 层
│   │   │   ├── pages/         # 页面 (ExplorerPage)
│   │   │   ├── widgets/       # 局部组件 (FileList, FileGrid, Breadcrumb)
│   │   │   └── dialogs/       # 弹窗 (重命名, 属性)
│   │   └── logic/             # 状态管理 (ExplorerController/Bloc - 处理当前路径、选中状态)
│   ├── headerBar              # 标题栏(显示当前信息，提供窗口控制按钮，显示当前路径，地址栏，菜单栏)
│   ├── sidebar/               # 左侧导航栏 (快速访问, 磁盘列表)
│   ├── mainContent/           # 主内容区域 (文件列表, 预览面板)
│   ├── preview/               # 预览面板 (图片, 文本预览逻辑)
│   ├── search/                # 搜索功能
│   └── settings/              # 设置页面
└── shared/                    # 共享 UI 组件
    └── widgets/               # 通用小组件 (LoadingSpinner, CustomButton, ContextMenu)
```
