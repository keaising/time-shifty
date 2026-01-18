# Time-Shifty ⏰

一个优雅的 macOS 菜单栏应用，显示多个时区的时间，鼠标悬停时窗口会自动移动到屏幕的不同角落。

## 功能特性

- 🌍 显示多个城市的实时时间
- 🖱️ 鼠标悬停自动移动窗口（顺时针：左上 → 右上 → 右下 → 左下）
- 🎨 毛玻璃材质的现代化 UI
- 📍 纯菜单栏应用，不占用 Dock 空间
- ⚙️ 窗口尺寸根据城市数量自动调整
- 🌐 多语言支持（中文/English）
- 🔧 完整的设置界面
  - 自定义城市和时区（按 UTC 偏移量排序）
  - 选择时间格式（24 小时/12 小时/自定义格式）
  - 多屏幕支持，选择显示屏幕
  - 语言切换（简体中文/English/跟随系统）

## 系统要求

- macOS 12.0 或更高版本
- Xcode 14.0 或更高版本（用于构建）

## 快速开始

### 开发调试

```bash
# 克隆仓库
git clone <repo-url>
cd time-shifty

# 在 Xcode 中打开
open time-shifty.xcodeproj

# 或使用命令行构建并运行
make debug
```

### 构建方法

#### 方法 1: 使用 Makefile（推荐）

```bash
# 查看所有命令
make help

# 构建 Release 版本
make release

# 安装到系统
make install

# 清理构建产物
make clean
```

#### 方法 2: 使用构建脚本

```bash
# 构建 Release 版本
./build_release.sh

# 手动安装
sudo cp -r release_build/Time-Shifty.app /Applications/
```

#### 方法 3: 在 Xcode 中手动构建

1. 打开 `time-shifty.xcodeproj`
2. 选择 Product → Scheme → Edit Scheme
3. 将 Run 配置改为 **Release**
4. 按 Cmd+B 构建
5. 在 Finder 中找到 `Build/Products/Release/time-shifty.app`
6. 拖拽到 `/Applications` 文件夹

## 使用方法

### 基本操作

1. **查看时间**：时钟窗口会显示所有配置城市的当前时间
2. **移动窗口**：将鼠标移到时钟窗口上，窗口会自动移动到屏幕的下一个角
3. **显示/隐藏**：点击菜单栏图标 → "显示/隐藏窗口"
4. **退出应用**：点击菜单栏图标 → "退出"

### 设置功能

点击菜单栏图标 → "设置..."（或使用快捷键 **Cmd+,**）打开设置窗口

#### 城市和时区

- **添加城市**：
  - 点击 "添加城市" 按钮打开城市选择器
  - 支持中英文搜索（如："北京"、"Beijing"、"UTC+8"）
  - 默认显示热门城市，可切换查看所有 50+ 个城市
  - 显示 UTC 偏移量，方便选择正确时区
  - 点击城市选中，再点击"添加"按钮确认
- **删除城市**：点击每行右侧的红色垃圾桶图标 🗑️
- **调整顺序**：拖拽左侧的 ☰ 图标重新排序
- **重置**：点击 "重置为默认" 恢复默认城市列表

#### 显示设置

- **时间格式**：
  - 预设格式：24 小时制、12 小时制、简短格式
  - **自定义格式**：支持自定义时间格式，如：
    - `HH:mm:ss` → 14:30:00 (24 小时)
    - `h:mm:ss a` → 2:30:00 PM (12 小时)
    - `yyyy-MM-dd HH:mm` → 2026-01-15 14:30
    - `MM/dd HH:mm` → 01/15 14:30
  - 实时预览当前格式效果
- **屏幕选择**：如果有多个显示器，可以选择时钟窗口显示在哪个屏幕上

所有设置会自动保存，下次启动应用时自动恢复。

## CI/CD 集成示例

### GitHub Actions

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Release
        run: make release
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: Time-Shifty.app
          path: release_build/Time-Shifty.app
```

## 项目结构

```
time-shifty/
├── time-shifty/
│   ├── time_shiftyApp.swift    # 应用入口和窗口管理
│   ├── ContentView.swift       # UI 界面
│   └── Assets.xcassets/        # 资源文件
├── Makefile                    # 构建命令
├── build_release.sh            # Release 构建脚本
├── update_app.sh              # 快速更新脚本
└── README.md                   # 本文件
```

## 技术栈

- **SwiftUI**: UI 框架
- **AppKit**: 窗口管理和菜单栏集成
- **Combine**: 定时器实现

## 开发者笔记

### Debug vs Release

- **Debug**: 包含调试符号，未优化，体积较大
- **Release**: 优化编译，体积小，性能好

### 代码签名

目前项目使用本地开发证书。如需分发给其他人，需要：

1. 配置 Apple Developer 账号
2. 在 Xcode 中设置 Team 和签名证书
3. 启用 Hardened Runtime
4. 进行 Notarization（公证）

## License

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
