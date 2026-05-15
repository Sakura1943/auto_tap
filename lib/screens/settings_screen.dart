import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.get('settings')),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _section(tr.get('language'), theme.colorScheme.primary),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder(
                valueListenable: localeNotifier,
                builder: (context, Locale locale, child) {
                  return SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'zh', label: Text('中文')),
                      ButtonSegment(value: 'en', label: Text('English')),
                    ],
                    selected: {locale.languageCode},
                    onSelectionChanged: (v) => _setLanguage(v.first),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(tr.get('theme'), theme.colorScheme.primary),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder(
                valueListenable: themeModeNotifier,
                builder: (context, ThemeMode mode, child) {
                  return SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(value: ThemeMode.system, label: Text(tr.get('themeSystem'))),
                      ButtonSegment(value: ThemeMode.light,  label: Text(tr.get('themeLight'))),
                      ButtonSegment(value: ThemeMode.dark,   label: Text(tr.get('themeDark'))),
                    ],
                    selected: {mode},
                    onSelectionChanged: (v) => _setTheme(v.first),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(tr.get('about'), theme.colorScheme.primary),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(tr.get('about')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

Future<void> _setLanguage(String code) async {
  localeNotifier.value = Locale(code);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('languageCode', code);
}

Future<void> _setTheme(ThemeMode mode) async {
  themeModeNotifier.value = mode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('themeMode', mode.name);
}
