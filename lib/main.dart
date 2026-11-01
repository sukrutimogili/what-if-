import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'screens/boot_screens.dart';
import 'services/journal_db.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  JournalDb.initPlatform();
  runApp(const WhatIfApp());
}

class WhatIfApp extends StatefulWidget {
  const WhatIfApp({super.key});

  @override
  State<WhatIfApp> createState() => _WhatIfAppState();
}

class _WhatIfAppState extends State<WhatIfApp> {
  final AppState _state = AppState();
  late Future<void> _boot;

  @override
  void initState() {
    super.initState();
    _boot = _state.init();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() => _boot = _state.init());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What If?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // AppScope sits above the Navigator so pushed screens can read it too.
      builder: (context, child) =>
          AppScope(state: _state, child: child ?? const SizedBox.shrink()),
      home: FutureBuilder<void>(
        future: _boot,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashScreen();
          }
          if (snapshot.hasError) {
            return StartupErrorScreen(
              error: snapshot.error,
              onRetry: _retry,
            );
          }
          return const AppShell();
        },
      ),
    );
  }
}
