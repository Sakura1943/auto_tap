import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/clicker_channel.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _delayController = TextEditingController(text: '1000');
  final _countController = TextEditingController(text: '');

  bool _overlayShown = false;
  bool _isClicking = false;
  bool _accessibilityEnabled = false;
  bool _overlayPermission = false;
  int _currentClicks = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _delayController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
      _checkOverlayState();
    }
  }

  Future<void> _init() async {
    await _loadSettings();
    _setupMethodCallHandler();
    await _checkPermissions();
    await _checkOverlayState();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _delayController.text = prefs.getInt('delayMs')?.toString() ?? '1000';
        final count = prefs.getInt('clickCount');
        _countController.text = count != null && count >= 0 ? count.toString() : '';
      });
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final delay = int.tryParse(_delayController.text) ?? 1000;
      final countText = _countController.text.trim();
      final count = countText.isEmpty ? -1 : (int.tryParse(countText) ?? -1);
      await prefs.setInt('delayMs', delay);
      await prefs.setInt('clickCount', count);
    } catch (_) {}
  }

  Future<void> _checkPermissions() async {
    try {
      final access = await ClickerChannel.isAccessibilityEnabled();
      final overlay = await ClickerChannel.canDrawOverlays();
      if (!mounted) return;
      setState(() {
        _accessibilityEnabled = access;
        _overlayPermission = overlay;
      });
    } catch (_) {}
  }

  void _setupMethodCallHandler() {
    ClickerChannel.setMethodCallHandler((call) async {
      if (call.method == 'stateUpdated') {
        final args = call.arguments as Map;
        setState(() => _isClicking = args['isRunning'] as bool? ?? false);
      }
    });
  }

  Future<void> _checkOverlayState() async {
    try {
      final state = await ClickerChannel.getState();
      if (state != null && mounted) {
        setState(() {
          _isClicking = state['isRunning'] as bool? ?? false;
          _currentClicks = state['currentClicks'] as int? ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _start() async {
    if (!_accessibilityEnabled) {
      _showAccessibilityDialog();
      return;
    }
    if (!_overlayPermission) {
      await _openOverlayPermissionSettings();
      if (!_overlayPermission) return;
    }

    final delay = int.tryParse(_delayController.text) ?? 1000;
    final countText = _countController.text.trim();
    final count = countText.isEmpty ? -1 : (int.tryParse(countText) ?? -1);

    await _saveSettings();
    await ClickerChannel.updateConfig(delayMs: delay, clickCount: count);

    try {
      await ClickerChannel.showOverlay();
      setState(() {
        _overlayShown = true;
        _isClicking = false;
      });
      _pollState();
    } catch (e) {
      if (mounted) {
        final tr = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr.get('startFailed')}: $e')),
        );
      }
    }
  }

  Future<void> _stop() async {
    await ClickerChannel.stopClicking();
    await ClickerChannel.hideOverlay();
    setState(() {
      _overlayShown = false;
      _isClicking = false;
    });
  }

  void _pollState() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!mounted || !_overlayShown) { timer.cancel(); return; }
      final state = await ClickerChannel.getState();
      if (state != null && mounted) {
        setState(() {
          _isClicking = state['isRunning'] as bool? ?? false;
          _currentClicks = state['currentClicks'] as int? ?? 0;
        });
      }
    });
  }

  Future<bool> _openOverlayPermissionSettings() async {
    await ClickerChannel.openOverlayPermissionSettings();
    await Future.delayed(const Duration(seconds: 2));
    await _checkPermissions();
    return _overlayPermission;
  }

  void _showAccessibilityDialog() {
    final tr = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.get('needAccessibilityTitle')),
        content: Text(tr.get('needAccessibilityBody')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr.get('cancel'))),
          FilledButton(onPressed: () { Navigator.pop(ctx); _openAccessibilitySettings(); }, child: Text(tr.get('goSettings'))),
        ],
      ),
    );
  }

  Future<void> _openAccessibilitySettings() async {
    await ClickerChannel.openAccessibilitySettings();
    await Future.delayed(const Duration(seconds: 2));
    await _checkPermissions();
  }

  String get _clickCountLabel {
    final t = _countController.text.trim();
    final c = t.isEmpty ? -1 : (int.tryParse(t) ?? -1);
    return c < 0 ? '∞' : '$c';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context);
    final disabled = _overlayShown;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.get('appTitle')),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: tr.get('settings'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          if (_overlayShown)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isClicking ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isClicking ? '${tr.get('running')}: $_currentClicks/$_clickCountLabel' : tr.get('paused'),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPermissionCard(theme, tr),
          const SizedBox(height: 12),
          _buildConfigCard(theme, tr, disabled),
          const SizedBox(height: 24),
          _buildMainButton(theme, tr),
          const SizedBox(height: 16),
          if (_overlayShown)
            Center(
              child: Text(
                _isClicking ? tr.get('overlayActive') : tr.get('overlayPaused'),
                style: theme.textTheme.bodyMedium?.copyWith(color: _isClicking ? Colors.green : Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(ThemeData theme, AppLocalizations tr) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.security, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(tr.get('permissions'), style: theme.textTheme.titleMedium),
                const Spacer(),
                IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _checkPermissions, tooltip: tr.get('refresh')),
              ],
            ),
            const SizedBox(height: 12),
            _permissionRow(tr.get('accessibility'), _accessibilityEnabled, tr.get('accessibilityHint'), _accessibilityEnabled ? null : _openAccessibilitySettings, tr),
            const SizedBox(height: 8),
            _permissionRow(tr.get('overlay'), _overlayPermission, tr.get('overlayHint'), _overlayPermission ? null : _openOverlayPermissionSettings, tr),
          ],
        ),
      ),
    );
  }

  Widget _permissionRow(String label, bool granted, String hint, VoidCallback? onTap, AppLocalizations tr) {
    return Row(
      children: [
        Icon(granted ? Icons.check_circle : Icons.cancel, color: granted ? Colors.green : Colors.red, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        if (!granted && onTap != null) TextButton(onPressed: onTap, child: Text(tr.get('enable'))),
      ],
    );
  }

  Widget _buildConfigCard(ThemeData theme, AppLocalizations tr, bool disabled) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.tune, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(tr.get('clickConfig'), style: theme.textTheme.titleMedium)]),
            const SizedBox(height: 16),
            TextField(
              controller: _delayController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !disabled,
              decoration: InputDecoration(labelText: tr.get('delayLabel'), hintText: tr.get('delayHint'), helperText: tr.get('delayHelper'), border: const OutlineInputBorder(), suffixText: 'ms'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !disabled,
              decoration: InputDecoration(labelText: tr.get('countLabel'), hintText: tr.get('countHint'), helperText: tr.get('countHelper'), border: const OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(ThemeData theme, AppLocalizations tr) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _overlayShown ? _stop : _start,
        icon: Icon(_overlayShown ? Icons.stop : Icons.play_arrow, size: 28),
        label: Text(_overlayShown ? tr.get('stop') : tr.get('start'), style: const TextStyle(fontSize: 18)),
        style: FilledButton.styleFrom(backgroundColor: _overlayShown ? Colors.red : theme.colorScheme.primary),
      ),
    );
  }
}
