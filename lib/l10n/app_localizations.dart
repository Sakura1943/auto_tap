import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const _strings = {
    'appTitle':       { 'zh': '屏幕点击器',           'en': 'Auto Tap' },
    'permissions':    { 'zh': '权限状态',             'en': 'Permissions' },
    'refresh':        { 'zh': '刷新',                 'en': 'Refresh' },
    'accessibility':  { 'zh': '无障碍服务',           'en': 'Accessibility' },
    'accessibilityHint':  { 'zh': '执行屏幕点击',     'en': 'Perform screen taps' },
    'overlay':        { 'zh': '悬浮窗权限',           'en': 'Overlay' },
    'overlayHint':    { 'zh': '显示悬浮操作按钮',     'en': 'Show floating button' },
    'enable':         { 'zh': '开启',                 'en': 'Enable' },
    'clickConfig':    { 'zh': '点击配置',             'en': 'Click Config' },
    'delayLabel':     { 'zh': '点击延迟（毫秒）',     'en': 'Click Delay (ms)' },
    'delayHint':      { 'zh': '默认 1000ms = 1秒',    'en': 'Default 1000ms = 1s' },
    'delayHelper':    { 'zh': '两次点击之间的间隔时间', 'en': 'Interval between clicks' },
    'countLabel':     { 'zh': '点击次数（可选）',     'en': 'Click Count (optional)' },
    'countHint':      { 'zh': '留空表示无限次',       'en': 'Empty for unlimited' },
    'countHelper':    { 'zh': '达到次数后自动停止',   'en': 'Auto stop when reached' },
    'start':          { 'zh': '开始',                 'en': 'Start' },
    'stop':           { 'zh': '停止',                 'en': 'Stop' },
    'running':        { 'zh': '运行中',               'en': 'Running' },
    'paused':         { 'zh': '已暂停',               'en': 'Paused' },
    'overlayActive':  { 'zh': '悬浮窗运行中 — 点击圆圈可暂停',  'en': 'Active — tap circle to pause' },
    'overlayPaused':  { 'zh': '悬浮窗已显示 — 点击圆圈开始',    'en': 'Overlay shown — tap circle to start' },
    'startFailed':    { 'zh': '启动失败',             'en': 'Start failed' },
    'needAccessibilityTitle':  { 'zh': '需要无障碍服务',       'en': 'Accessibility Required' },
    'needAccessibilityBody':   { 'zh': '此应用需要开启无障碍服务才能执行自动点击。', 'en': 'This app requires the accessibility service to perform auto taps.' },
    'cancel':         { 'zh': '取消',                 'en': 'Cancel' },
    'goSettings':     { 'zh': '前往设置',             'en': 'Go to Settings' },
    'notificationTitle': { 'zh': '屏幕点击器',        'en': 'Auto Tap' },
    'notificationText': { 'zh': '拖拽移动位置（点击在圆圈下方）', 'en': 'Drag to move (clicks below circle)' },
    'settings':      { 'zh': '设置',                  'en': 'Settings' },
    'language':      { 'zh': '语言',                  'en': 'Language' },
    'theme':         { 'zh': '主题',                  'en': 'Theme' },
    'themeSystem':   { 'zh': '跟随系统',              'en': 'Follow System' },
    'themeLight':    { 'zh': '浅色',                  'en': 'Light' },
    'themeDark':     { 'zh': '深色',                  'en': 'Dark' },
    'about':         { 'zh': '关于',                  'en': 'About' },
    'appDescription': { 'zh': '基于 Flutter 的 Android 自动点击应用，通过无障碍服务实现屏幕任意位置的自动点击。使用Claude Code生成。', 'en': 'An Android auto-clicker built with Flutter, using AccessibilityService to perform taps anywhere. Generated with Claude Code.' },
    'sourceCode':    { 'zh': '源代码',                'en': 'Source Code' },
    'checkUpdate':   { 'zh': '检查更新',              'en': 'Check for Updates' },
    'followSystem':  { 'zh': '跟随系统',              'en': 'Follow System' },
  };

  String get(String key) => _strings[key]?[locale.languageCode] ?? _strings[key]?['en'] ?? key;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const supportedLocales = [Locale('zh', 'CN'), Locale('en', 'US')];

  static Future<Locale> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString('languageCode') ?? 'zh';
      return Locale(code);
    } catch (_) {
      return const Locale('zh');
    }
  }

  static Future<void> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', locale.languageCode);
    } catch (_) {}
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
