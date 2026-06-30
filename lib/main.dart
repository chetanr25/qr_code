import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_prefs.dart';
import 'core/app_theme.dart';
import 'core/history_store.dart';
import 'features/home/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AppPrefs.instance.init();
  await HistoryStore.instance.init();
  runApp(const QrlyApp());
}

class QrlyApp extends StatelessWidget {
  const QrlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppPrefs.instance.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Qrly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const HomeShell(),
        );
      },
    );
  }
}
