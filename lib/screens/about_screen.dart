import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

const _appVersion = '1.1.0';
const _githubUrl = 'https://github.com/Sakura1943/auto_tap';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.get('about')),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/icon.png', width: 96, height: 96),
                ),
                const SizedBox(height: 16),
                Text(tr.get('appTitle'),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('v$_appVersion',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(tr.get('appDescription'),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Card(
            child: ListTile(
              leading: const Icon(Icons.code),
              title: Text(tr.get('sourceCode')),
              subtitle: const Text('GitHub'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openUrl(_githubUrl),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.system_update),
              title: Text(tr.get('checkUpdate')),
              subtitle: const Text('GitHub Releases'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openUrl('$_githubUrl/releases'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
