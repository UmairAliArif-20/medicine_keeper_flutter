import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double currentFontSize = 16.0;
  int selectedPageIndex = 0;

  // Update the font size for all pages.
  void updateFontSize(double newSize) {
    setState(() {
      currentFontSize = newSize;
    });
  }

  List<Widget> _pages() {
    return <Widget>[
      HomePage(fontSize: currentFontSize),
      SettingsPage(fontSize: currentFontSize, onChanged: updateFontSize),
      LoginPage(fontSize: currentFontSize),
    ];
  }

  List<BottomNavigationBarItem> _navigationItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
