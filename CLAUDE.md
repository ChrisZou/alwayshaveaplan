# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

AlwaysHaveAPlan 是一个用 SwiftUI 和 SwiftPM 构建的 macOS 应用，监听屏幕解锁/唤醒事件，在浮动窗口中显示当前正在进行的日程。

**核心理念**：每一块时间都应该有计划地度过。让用户在每次解锁 Mac 时，直面"当前想要做什么？"这个问题。如果有日程在进行，就显示出来提醒；如果没有日程，就用这个问题唤起用户的自我觉察，并且强迫用户必须设置一个计划，避免漫无目的地浪费时间。 

**Bundle ID**: `com.chriszou.alwayshaveaplan`

**App Icon**: Sources/App/Resources/AppIcon.icns

## 构建与运行

### 构建
```sh
swift build
```

### 运行
```sh
swift run
```

**重要**：`swift run` 会在 `./run/AlwaysHaveAPlan.app` 创建/更新一个独立的 app bundle 并启动它。这是获取日历权限提示所必需的。

### 用 Xcode 打开
在 Xcode 中打开 `Package.swift` (File → Open)，然后运行。

## 架构

### 启动引导流程
应用使用独特的引导机制 (Sources/App/Bootstrapper.swift:6)：
1. 通过 `swift run` 运行时，可执行文件最初不在 `.app` bundle 中
2. `Bootstrapper.shouldContinueInProcess()` 检测到这一点，在 `./run/AlwaysHaveAPlan.app` 创建 app bundle
3. 将可执行文件复制到 bundle 中，创建带日历权限的 `Info.plist`
4. 启动 bundle 版本，终止引导进程
5. Bundle 版本继续正常的应用初始化

这种方式让 `swift run` 能够工作，同时仍能获得正确的 macOS 权限对话框。

### 核心组件

**AppDelegate** (Sources/App/AppDelegate.swift:4)
- 引导后的入口点
- 使用 `SMAppService.mainApp.register()` 将应用注册为登录项 (macOS 13+)
- 初始化 `AppController`

**AppController** (Sources/App/AppController.swift:4)
- 主要协调逻辑
- 通过 `NSWorkspace` 通知和 `DistributedNotificationCenter` 监听解锁/唤醒事件：
  - `sessionDidBecomeActiveNotification`
  - `screensDidWakeNotification`
  - `didWakeNotification`
  - `com.apple.screenIsUnlocked` (分布式通知)
- 通过 `Timer` 每 60 秒运行一次定期检查
- 用 0.5 秒延迟去抖，避免重复触发
- 根据日历数据决定显示事件还是提示

**CalendarManager** (Sources/App/CalendarManager.swift:4)
- 封装 `EventKit` 进行日历访问
- 只查询标题为"日程安排"的日历中的事件 (targetCalendarTitle)
- 过滤出"正在进行"的事件 (`startDate <= now && endDate > now`)
- 处理 macOS 14+ (`.fullAccess`) 和旧版本 (`.authorized`) 的权限模型

**WindowManager** (Sources/App/WindowManager.swift:5)
- 管理一个可以显示两种状态的浮动窗口：
  1. 提示视图："你想干什么？" + "检查日程" 按钮
  2. 事件视图：当前事件列表
- 窗口使用 `.floating` 级别和 `[.canJoinAllSpaces, .fullSizeContentView]`
- 使用 `NSHostingView` 将 SwiftUI 视图桥接到 AppKit 窗口
- 事件显示 3 秒后自动隐藏
- 窗口居中，尺寸为屏幕的 70%

**Logger** (Sources/App/Logger.swift:3)
- 将日志写入 stderr 和 `~/Library/Logs/AlwaysHaveAPlan.log`
- 使用串行 dispatch queue 确保线程安全的文件写入
- ISO8601 格式的时间戳

**Todo 模型** (Sources/App/Models/Todo.swift:3)
- 待办事项的数据结构（目前未使用）
- 包含 id, text, desc, position, isCompleted, createdAt, updatedAt 字段

### 事件流程

1. **检测到屏幕解锁** → `AppController` 用 0.5 秒去抖调度检查
2. **执行检查** → `CalendarManager.fetchCurrentEvents()` 查询"日程安排"日历
3. **如果有事件** → `WindowManager.showFloatingEvents()` 显示它们 3 秒
4. **如果没有事件** → `WindowManager.showFloatingPrompt()` 显示提示 + 在后台打开 Calendar.app
5. **用户点击"检查日程"** → 触发手动检查（如果有事件则显示，但不打开 Calendar.app）
6. **定期计时器 (60秒)** → 静默检查，如果有事件且 showEventsIfAny=false 则不显示 UI

### 关键设计决策

- **单一浮动窗口**：对提示和事件显示复用同一个窗口，避免多个覆盖层
- **目标日历过滤**：只显示"日程安排"日历中的事件，避免噪音
- **后台启动 Calendar.app**：使用 `NSWorkspace.OpenConfiguration` 的 `activates = false` 在不抢夺焦点的情况下打开日历
- **登录项注册**：使用 `SMAppService` (macOS 13+) 自动注册开机启动
- **Bundle 要求**：macOS 要求 `.app` bundle 才能获取日历权限，因此需要引导机制

## 调试

**日志文件位置**: `~/Library/Logs/AlwaysHaveAPlan.log`

日志包含：
- 所有解锁/唤醒事件触发
- 日历权限状态
- 事件查询结果（带样本标题，或如果当前没有则显示附近的事件）
- 窗口显示/隐藏操作
- 引导过程详情

## 常见任务

### 修改目标日历
修改 Sources/App/CalendarManager.swift:6 中的 `CalendarManager.targetCalendarTitle`

### 调整自动隐藏时长
修改 Sources/App/AppController.swift:121 中 `AppController.performCheck()` 的 `autoHideAfter` 参数（当前 3 秒）

### 修改定期检查间隔
修改 Sources/App/AppController.swift:73 中 `AppController.startPeriodicChecks()` 的计时器间隔（当前 60 秒）

### 修改窗口大小/位置
调整 Sources/App/WindowManager.swift:19 中 `WindowManager.showFloatingPrompt()` 的计算（当前屏幕的 70%）
