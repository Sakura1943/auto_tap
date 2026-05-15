import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';

final localeNotifier = ValueNotifier<Locale>(const Locale('zh'));
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final lang = prefs.getString('languageCode') ?? 'zh';
  localeNotifier.value = Locale(lang);

  final tm = prefs.getString('themeMode');
  themeModeNotifier.value = switch (tm) {
    'dark'  => ThemeMode.dark,
    'light' => ThemeMode.light,
    _       => ThemeMode.system,
  };

  runApp(const ClickerApp());
}

class ClickerApp extends StatelessWidget {
  const ClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: localeNotifier,
      builder: (context, Locale locale, child) {
        return ValueListenableBuilder(
          valueListenable: themeModeNotifier,
          builder: (context, ThemeMode themeMode, child) {
            return MaterialApp(
              title: 'Auto Tap',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}
