# auto_tap · 屏幕点击器

[![Build & Release](https://github.com/Sakura1943/auto_tap/actions/workflows/release.yml/badge.svg)](https://github.com/Sakura1943/auto_tap/actions)

基于 Flutter 的 Android 自动点击应用，通过无障碍服务实现屏幕任意位置的自动点击。使用 Claude Code 生成。

## 功能

- 可配置点击延迟（毫秒），默认 1000ms
- 可配置点击次数，默认无限次，0 次不点击
- 悬浮圆圈指示点击位置，拖拽移动，实时跟随
- 圆圈在点击目标上方，点击打在圆圈正下方
- 点击圆圈切换开始 / 暂停
- 中英文切换
- 浅色 / 深色 / 跟随系统主题切换
- 设置页 + 关于页

## 权限要求

| 权限 | 用途 |
|------|------|
| 无障碍服务 | 执行屏幕自动点击 |
| 悬浮窗权限 | 显示悬浮操作按钮 |

## 使用方式

1. 安装 APK 后打开应用
2. 在权限状态卡片中开启**无障碍服务**和**悬浮窗权限**
3. 设置点击延迟和点击次数
4. 点击**开始**，悬浮圆圈出现
5. 拖拽圆圈到目标位置上方，点击圆圈开始自动点击
6. 再次点击圆圈暂停，点击 App 内**停止**结束

## 项目结构

```
lib/
  main.dart                           # 入口 + 全局 theme/locale
  l10n/app_localizations.dart         # 中英文国际化
  screens/
    home_screen.dart                  # 主界面
    settings_screen.dart              # 设置（语言 / 主题）
    about_screen.dart                 # 关于（Logo / 版本 / GitHub）
  services/clicker_channel.dart       # MethodChannel 封装

android/app/src/main/
  kotlin/com/sakunia/auto_tap/
    MainActivity.kt                   # Flutter 与原生通信桥接
    ClickerAccessibilityService.kt    # 无障碍服务，执行屏幕点击
    ClickerState.kt                   # 共享状态管理
    OverlayService.kt                 # 悬浮窗服务
  res/
    drawable/                         # 图标和背景资源
    xml/accessibility_service_config.xml  # 无障碍服务配置

tool/
  generate_icon.dart                  # 图标生成工具（dart run）
```

## 构建

```bash
# 生成图标（如 assets/icon.png 已更新）
dart run tool/generate_icon.dart

# Debug / Release
flutter build apk --debug
flutter build apk --release
```

## 技术要点

- **无障碍服务** `dispatchGesture` 注入点击，`StrokeDescription(path, 0, 50)` 模拟 50ms 触摸
- **WindowManager** 悬浮窗，`TYPE_APPLICATION_OVERLAY`
- **点击偏移** 圆圈在点击位置上方，点击打在下方，永不干扰自身
- **持续点击** `Handler.postDelayed` 递归调度
- **主题和语言** `ValueNotifier` 驱动，切换不刷新页面
- **前台服务** Android 14+ `FOREGROUND_SERVICE_TYPE_SPECIAL_USE`
- **BroadcastReceiver** Android 14+ `RECEIVER_NOT_EXPORTED`
- **R8 混淆** ProGuard 规则保护 service 类
