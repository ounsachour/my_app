import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ أضف هذا
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'onboarding_screen.dart';
import 'app_translations.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final savedDarkMode = prefs.getBool('isDarkMode') ?? false;
  final savedLanguage = prefs.getString('language_code') ?? 'en';
  
  print('🟢 Loading saved theme: isDarkMode = $savedDarkMode');
  print('🟢 Loading saved language: $savedLanguage');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(initialDarkMode: savedDarkMode)),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ==================== Theme Provider ====================
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider({bool initialDarkMode = false}) : _isDarkMode = initialDarkMode {
    print('🟢 ThemeProvider created with isDarkMode = $_isDarkMode');
  }
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    print('🟢 Theme toggled: isDarkMode = $_isDarkMode');
    notifyListeners();
  }
  
  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
  
  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }
  
  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF005B5B),
    scaffoldBackgroundColor: const Color(0xFFFBFBFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey,
    iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
      bodyMedium: TextStyle(color: Color(0xFF1A1A1A)),
      titleLarge: TextStyle(color: Color(0xFF1A1A1A)),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF005B5B),
      secondary: Color(0xFF005B5B),
    ),
  );
  
  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF005B5B),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: Colors.grey,
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF005B5B),
      secondary: Color(0xFF005B5B),
    ),
  );
}

// ==================== MyApp ====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        print('🟢 MyApp build: isDarkMode = ${themeProvider.isDarkMode}');
        return MaterialApp(
          title: 'Elderly Care',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          locale: Locale(languageProvider.currentLanguage),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,      // ✅ أضف هذا
            GlobalWidgetsLocalizations.delegate,       // ✅ أضف هذا
            GlobalCupertinoLocalizations.delegate,     // ✅ أضف هذا
          ],
          home: const OnboardingScreen(),
        );
      },
    );
  }
}

// ==================== HomePage (مثال) ====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List users = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final response = await http.get(

      Uri.parse('${AppConfig.baseUrl}/api/get_data.php'),

    );

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              users[index]['first_name'].toString(),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          );
        },
      ),
    );
  }
}