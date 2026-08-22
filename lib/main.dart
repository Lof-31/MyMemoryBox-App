import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

const List<Color> appThemeColors = [
  Colors.deepPurple,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.red,
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StorageService _storageService = StorageService();
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadThemeColor();
  }

  Future<void> _loadThemeColor() async {
    final index = await _storageService.getThemeColorIndex();
    setState(() {
      _colorIndex = (index >= 0 && index < appThemeColors.length) ? index : 0;
    });
  }

  void updateThemeColor(int newIndex) {
    setState(() {
      _colorIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = appThemeColors[_colorIndex];

    return MaterialApp(
      title: 'My Memory Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(
        onThemeChanged: updateThemeColor,
      ),
    );
  }
}