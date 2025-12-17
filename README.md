# AlwaysHaveAPlan

[English](#english) | [中文](#中文)

---

## English

A macOS app that helps you stay intentional with your time by showing your current schedule when you unlock your Mac.

### Philosophy

Every moment should have a plan. When you unlock your Mac, you should be confronted with the question: "What do you want to do?" If you have a scheduled event, it reminds you. If not, it prompts you to create one, preventing aimless time-wasting.

### Features

- 🔓 **Unlock Detection**: Automatically shows your current schedule when you unlock or wake your Mac
- 📅 **Calendar Integration**: Reads from your "日程安排" (Schedule) calendar
- ⏱️ **Progress Tracking**: Shows real-time progress and remaining time for current events
- 🎨 **Beautiful UI**: Clean, modern interface with smooth animations
- 🚫 **No Distractions**:
  - Auto-hides after 3 seconds when showing events
  - Stops periodic checks when no events exist to avoid focus interruption
- ⌨️ **No Accidental Quit**: Command+Q is disabled to prevent accidental closure
- 🔄 **Auto-start**: Registers as a login item automatically

### Requirements

- macOS 14.0 or later
- Calendar access permission

### Installation

#### Option 1: Build from Source

```sh
# Clone the repository
git clone https://github.com/yourusername/alwayshaveaplan.git
cd alwayshaveaplan

# Build and run
swift run
```

#### Option 2: Build Release Version

```sh
./build-release.sh
```

The app will be created at `run/release/AlwaysHaveAPlan.app`. You can copy it to your Applications folder.

### Usage

1. **First Launch**: Grant Calendar access when prompted
2. **Setup Calendar**: Create a calendar named "日程安排" (Schedule) in Calendar.app
3. **Add Events**: Add your daily events to this calendar
4. **Unlock and See**: Every time you unlock your Mac, you'll see your current schedule

### Development

```sh
# Run in development mode (terminal stays open, Ctrl+C to quit)
swift run

# Build
swift build

# Build release version
./build-release.sh
```

**Logs**: `~/Library/Logs/AlwaysHaveAPlan.log`

### Configuration

- **Target Calendar**: Modify `CalendarManager.targetCalendarTitle` in `Sources/App/CalendarManager.swift`
- **Auto-hide Duration**: Modify `autoHideAfter` parameter in `Sources/App/AppController.swift`
- **Periodic Check Interval**: Modify timer interval in `Sources/App/AppController.swift`

### Architecture

- **Bootstrapper**: Creates app bundle for Calendar permissions
- **AppController**: Manages unlock detection and event checking
- **CalendarManager**: Handles EventKit integration
- **WindowManager**: Manages floating window display
- **FloatingPromptView**: SwiftUI interface

For detailed architecture, see [CLAUDE.md](CLAUDE.md).

### License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 中文

一个 macOS 应用，通过在解锁 Mac 时显示当前日程，帮助你有计划地度过每一刻。

### 核心理念

每一块时间都应该有计划地度过。当你解锁 Mac 时，应该直面"你想干什么？"这个问题。如果有日程在进行，就显示出来提醒；如果没有日程，就用这个问题唤起自我觉察，避免漫无目的地浪费时间。

### 功能特性

- 🔓 **解锁检测**：自动在解锁或唤醒 Mac 时显示当前日程
- 📅 **日历集成**：从"日程安排"日历中读取事件
- ⏱️ **进度追踪**：实时显示当前事件的进度和剩余时间
- 🎨 **精美界面**：简洁现代的界面设计，流畅的动画效果
- 🚫 **无干扰模式**：
  - 显示事件后 3 秒自动隐藏
  - 无日程时停止定期检查，避免焦点被打断
- ⌨️ **防止误退出**：禁用 Command+Q，防止误关闭
- 🔄 **开机自启**：自动注册为登录项

### 系统要求

- macOS 14.0 或更高版本
- 日历访问权限

### 安装方法

#### 方式一：从源码构建

```sh
# 克隆仓库
git clone https://github.com/yourusername/alwayshaveaplan.git
cd alwayshaveaplan

# 构建并运行
swift run
```

#### 方式二：构建发行版

```sh
./build-release.sh
```

应用会被创建在 `run/release/AlwaysHaveAPlan.app`，你可以将它复制到应用程序文件夹。

### 使用说明

1. **首次启动**：根据提示授予日历访问权限
2. **设置日历**：在日历 App 中创建名为"日程安排"的日历
3. **添加事件**：将你的日常安排添加到这个日历中
4. **解锁查看**：每次解锁 Mac 时，都会看到当前的日程

### 开发

```sh
# 开发模式运行（终端保持打开，Ctrl+C 退出）
swift run

# 构建
swift build

# 构建发行版
./build-release.sh
```

**日志位置**：`~/Library/Logs/AlwaysHaveAPlan.log`

### 配置选项

- **目标日历**：修改 `Sources/App/CalendarManager.swift` 中的 `CalendarManager.targetCalendarTitle`
- **自动隐藏时长**：修改 `Sources/App/AppController.swift` 中的 `autoHideAfter` 参数
- **定期检查间隔**：修改 `Sources/App/AppController.swift` 中的计时器间隔

### 架构说明

- **Bootstrapper**：创建 app bundle 以获取日历权限
- **AppController**：管理解锁检测和事件检查
- **CalendarManager**：处理 EventKit 集成
- **WindowManager**：管理浮动窗口显示
- **FloatingPromptView**：SwiftUI 界面

详细架构说明请查看 [CLAUDE.md](CLAUDE.md)。

### 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件。
