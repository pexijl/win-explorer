# lib 目录结构

```
lib/
├── main.dart
├── components/               # 组件
│   ├── BottomBar/
│   ├── HeaderBar/
│   ├── MainContent/          # 主内容组件
│   │   ├── create_directory_dialog.dart
│   │   ├── create_file_dialog.dart
│   │   ├── delete_dialog.dart
│   │   ├── drive_item.dart
│   │   ├── entity_property_dialog.dart
│   │   ├── file_system_context_menu.dart
│   │   ├── file_system_entity_grid_item.dart
│   │   ├── file_system_entity_list_item.dart
│   │   ├── file_system_grid_view.dart
│   │   ├── file_system_list_view.dart
│   │   ├── rename_entity_dialog.dart
│   │   ├── this_computer.dart
│   ├── MainPage/             # 主页面组件
│   │   ├── bottom_bar.dart
│   │   ├── header_bar.dart
│   │   ├── main_content.dart
│   │   ├── sidebar.dart
│   └── Sidebar/              # 侧边栏组件
│       ├── sidebar_node_item.dart
│       ├── sidebar_tree_node.dart
│       └── sidebar_tree_view.dart
├── constants/                # 常量
│   └── global_constants.dart
├── entities/                 # 实体类
│   ├── app_directory.dart
│   ├── app_file_system_entity.dart
│   ├── app_file.dart
│   ├── clipboard_manager.dart
│   └── drive.dart
├── models/                   # 模型类
├── pages/                    # 页面
│   └── main_page.dart
├── services/                 # 服务类
│   ├── file_system_service.dart
│   ├── preference_service.dart
│   └── win32_drive_service.dart
├── shared/                   # 共享组件
│   └── widgets/
│       ├── double_tap_aware_detector.dart
│       └── resize_divider.dart
└── utils/                    # 工具类
    ├── search_filter.dart
    └── utils.dart
```
