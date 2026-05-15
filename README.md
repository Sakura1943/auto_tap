# 屏幕点击器

基于 Flutter 的 Android 自动点击应用，通过无障碍服务实现屏幕任意位置的自动点击。

## 功能

- 可配置点击延迟（毫秒），默认 1000ms
- 可配置点击次数，默认无限次
- 悬浮圆圈指示点击位置，拖拽即可移动
- 圆圈在点击目标上方，点击打在圆圈正下方
- 点击圆圈切换开始 / 暂停
- Material Design 3 界面

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
  main.dart                          # 入口
  screens/home_screen.dart           # 主界面
  services/clicker_channel.dart      # MethodChannel 封装

android/app/src/main/
  kotlin/com/sakunia/auto_tap/
    MainActivity.kt                  # Flutter 与原生通信桥接
    ClickerAccessibilityService.kt   # 无障碍服务，执行屏幕点击
    ClickerState.kt                  # 共享状态管理
    OverlayService.kt                # 悬浮窗服务
  res/
    drawable/                        # 图标和背景资源
    mipmap-anydpi-v26/               # 自适应应用图标
    xml/accessibility_service_config.xml  # 无障碍服务配置
```

## 构建

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release
```

## 技术要点

- **无障碍服务** `dispatchGesture` 注入点击事件，`StrokeDescription(path, 0, 50)` 模拟 50ms 触摸
- **WindowManager** 悬浮窗，`TYPE_APPLICATION_OVERLAY`
- **点击偏移设计** 圆圈在点击位置上方（半径 + 10dp 间距），点击打在下方，避免注入事件打到自身
- **持续点击** `Handler.postDelayed` 递归调度
- **前台服务** Android 14+ 适配 `FOREGROUND_SERVICE_TYPE_SPECIAL_USE`
- **BroadcastReceiver** Android 14+ 显式指定 `RECEIVER_NOT_EXPORTED`
- **R8 混淆** ProGuard 规则保护 service 类
