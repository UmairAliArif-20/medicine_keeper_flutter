import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/settings_page.dart';
import 'services/medicine_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double currentFontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await MedicineNotifications.instance.initialize(
      onNotificationTap: _handleNotificationTap,
    );
  }

  void _handleNotificationTap() {
    if (!mounted) {
      return;
    }

    setState(() {
      selectedPageIndex = 0;
    });
  }

  int selectedPageIndex = 0; // Starts back at Home (index 0) once logged in
  bool isLoggedIn =
      false; // Track login state to hide/show the navigation shell

  void updateFontSize(double newSize) {
    setState(() {
      currentFontSize = newSize;
    });
  }

  List<Widget> _pages() {
    return <Widget>[
      HomePage(fontSize: currentFontSize),
      SettingsPage(fontSize: currentFontSize, onChanged: updateFontSize),
    ];
  }

  List<BottomNavigationBarItem> _navigationItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 1. If the user is NOT logged in, show ONLY the login page with no extra navigation UI bars
    if (!isLoggedIn) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: AppColors.primary,
        ),
        home: LoginPage(
          fontSize: currentFontSize,
          onLoginSuccess: () {
            setState(() {
              isLoggedIn = true; // Flips state and unlocks full layout safely
            });
          },
        ),
      );
    }

    // 2. If logged in, load your exact untouched layout design with structural widgets
    List<Widget> pages = _pages();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(height: 1.4),
        ),
      ),
      home: ColoredBox(
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.accent.withValues(alpha: 0.25),
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            appBar: AppBar(
              title: const Text("Medicine Ledger"),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: SafeArea(child: pages[selectedPageIndex]),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              currentIndex: selectedPageIndex,
              items: _navigationItems(),
              onTap: (int tappedIndex) {
                setState(() {
                  selectedPageIndex = tappedIndex;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
