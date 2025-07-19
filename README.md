# 图像识别应用 (Image Recognition App)

一个基于 Flutter 开发的跨平台图像识别应用，支持上传图片并通过 AI 进行智能识别和分析。

## 功能特性

- 📸 **图片选择与上传**：支持从相册选择图片并上传到服务器
- 🤖 **智能图像识别**：集成 AI 图像识别 API，自动分析图片内容
- 💬 **聊天式界面**：采用现代化的聊天界面展示识别结果
- 💾 **历史记录**：自动保存识别历史，支持本地持久化存储
- 🎨 **Material Design 3**：采用最新的 Material Design 3 设计规范
- 🌐 **跨平台支持**：支持 Android、iOS、Web、Windows、macOS、Linux

## 技术栈

- **框架**: Flutter 3.5.3+
- **语言**: Dart
- **UI 设计**: Material Design 3
- **状态管理**: StatefulWidget
- **网络请求**: http 包
- **图片选择**: image_picker 包
- **本地存储**: shared_preferences 包
- **图标生成**: flutter_launcher_icons 包

## 项目结构

```
image_recognition/
├── lib/
│   ├── main.dart           # 应用主入口和主界面
│   └── config.dart         # 配置文件（API 地址等）
├── assets/
│   └── icon/              # 应用图标资源
│       ├── icon.png
│       └── icon_foreground.png
├── android/               # Android 平台配置
├── ios/                   # iOS 平台配置
├── web/                   # Web 平台配置
├── windows/               # Windows 平台配置
├── macos/                 # macOS 平台配置
├── linux/                 # Linux 平台配置
├── test/                  # 测试文件
├── pubspec.yaml           # 项目依赖配置
└── README.md             # 项目说明文档
```

## 核心功能模块

### 1. 图片上传模块
- 使用 `image_picker` 包选择图片
- 通过 HTTP multipart 请求上传图片到服务器
- 支持多种图片格式（JPEG、PNG 等）

### 2. 图像识别模块
- 调用后端 AI 图像识别 API
- 支持文字识别和物体识别
- 智能分析图片内容并返回详细描述

### 3. 消息管理模块
- 聊天式消息展示界面
- 支持图片和文本消息
- 本地持久化存储历史记录

### 4. 用户界面模块
- 现代化的 Material Design 3 界面
- 响应式布局设计
- 流畅的动画效果和交互体验

## 安装与运行

### 环境要求

- Flutter SDK 3.5.3 或更高版本
- Dart SDK 3.0.0 或更高版本
- Android Studio / VS Code（推荐）
- 对应平台的开发环境（Android SDK、Xcode 等）

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd image_recognition
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **生成应用图标**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **运行应用**
   ```bash
   # 运行在调试模式
   flutter run

   # 运行在发布模式
   flutter run --release

   # 指定平台运行
   flutter run -d chrome    # Web
   flutter run -d windows   # Windows
   flutter run -d macos     # macOS
   ```

## 配置说明

### API 配置

在 `lib/config.dart` 文件中配置后端 API 地址：

```dart
class AppConfig {
  static const String baseUrl = 'http://your-api-server.com';
  static const String uploadUrl = '$baseUrl/api/file/upload';
  static const String downloadUrl = '$baseUrl/api/file/download';
  static const String imageRecognitionUrl = '$baseUrl/api/image-recognition';
}
```

### 图标配置

在 `pubspec.yaml` 中配置应用图标：

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/icon.png"
```

## 主要依赖包

| 包名 | 版本 | 用途 |
|------|------|------|
| flutter | SDK | Flutter 框架 |
| image_picker | ^1.0.7 | 图片选择功能 |
| http | ^1.2.0 | HTTP 网络请求 |
| http_parser | ^4.0.2 | HTTP 解析工具 |
| shared_preferences | ^2.2.2 | 本地数据存储 |
| cupertino_icons | ^1.0.8 | iOS 风格图标 |
| flutter_launcher_icons | ^0.13.1 | 应用图标生成 |

## 使用说明

1. **选择图片**：点击底部的"选择图片"按钮，从相册中选择要识别的图片
2. **上传识别**：选择图片后，应用会自动上传并调用 AI 进行识别
3. **查看结果**：识别结果会以聊天消息的形式显示在界面上
4. **历史记录**：所有识别记录会自动保存，重启应用后仍可查看
5. **清除历史**：点击右上角的删除按钮可清除所有历史记录

## 开发说明

### 代码结构

- `main.dart`：包含应用的主要逻辑和 UI 组件
- `config.dart`：配置文件，包含 API 地址和识别提示词
- `ChatMessage` 类：消息数据模型，支持序列化和反序列化

### 关键特性

- **响应式设计**：适配不同屏幕尺寸和设备类型
- **错误处理**：完善的错误处理和用户提示机制
- **性能优化**：图片加载优化和内存管理
- **用户体验**：流畅的动画和直观的交互设计

## 构建发布

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

## 贡献指南

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 GitHub Issue
- 发送邮件至项目维护者

---

*本项目基于 Flutter 框架开发，致力于提供优秀的跨平台图像识别体验。*
