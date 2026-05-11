import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/gymradar/auth/login/login_widget.dart';
import '/gymradar/pages/home/home_widget.dart';
import 'app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FFAppState().initializePersistedState();

  runApp(
    ChangeNotifierProvider(
      create: (context) => FFAppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyApp of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<MyApp>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.light;

  void setLocale(String language) =>
      setState(() => _locale = Locale(language));

  void setThemeMode(ThemeMode mode) =>
      setState(() => _themeMode = mode);

  late final GoRouter _router = GoRouter(
    initialLocation: LoginWidget.routePath,
    routes: [
      GoRoute(
        name: LoginWidget.routeName,
        path: LoginWidget.routePath,
        builder: (context, state) => const LoginWidget(),
      ),
      GoRoute(
        name: HomeWidget.routeName,
        path: HomeWidget.routePath,
        builder: (context, state) => const HomeWidget(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GymRadar',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

