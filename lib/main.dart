import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'providers/job_provider.dart';
import 'providers/record_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted theme before runApp
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => JobProvider()..loadJobs()),
        ChangeNotifierProvider(create: (_) => RecordProvider()),
      ],
      child: const PuantajApp(),
    ),
  );
}

class PuantajApp extends StatelessWidget {
  const PuantajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, tp, _) {
        return MaterialApp(
          title: 'Puantajım',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: tp.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
