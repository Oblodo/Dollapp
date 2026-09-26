import 'package:flutter/material.dart';

import 'l10n/strings.dart';
import 'screens/home_screen.dart';
import 'services/settings_store.dart';

void main() {
  runApp(const DollfindApp());
}

class DollfindApp extends StatefulWidget {
  const DollfindApp({super.key});

  @override
  State<DollfindApp> createState() => _DollfindAppState();
}

class _DollfindAppState extends State<DollfindApp> {
  AppLocaleCode _locale = AppLocaleCode.nb;
  final _settings = SettingsStore();

  @override
  void initState() {
    super.initState();
    _settings.getLocale().then((v) => setState(() => _locale = v));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(_locale);
    return MaterialApp(
      title: 'Dollfind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB98A96)), // muted rose, matching the original palette
        textTheme: Typography.blackMountainView.apply(fontFamily: 'serif'),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB98A96), brightness: Brightness.dark),
      ),
      home: HomeScreen(
        s: s,
        onLocaleChanged: (code) => setState(() => _locale = code),
      ),
    );
  }
}
