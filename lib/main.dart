import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'data/medicine_database.dart';
import 'pages/account_page.dart';
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
  ThemeMode _themeMode = ThemeMode.light;
  final List<Map<String, dynamic>> _accounts = <Map<String, dynamic>>[
    <String, dynamic>{
      'email': 'rafaihabbasi@gmail.com',
      'password': '123456',
      'name': 'Rafai',
    },
  ];
  Map<String, dynamic>? _currentAccount;

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

  void _updateThemeMode(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _handleLoginSuccess(Map<String, dynamic> account) {
    final String email = (account['email'] as String? ?? '').trim();
    if (email.isEmpty) {
      setState(() {
        _currentAccount = Map<String, dynamic>.from(account);
        isLoggedIn = true;
        selectedPageIndex = 0; // Go to Home
      });
      return;
    }

    MedicineDatabase.instance
        .attachGuestMedicinesToOwner(email)
        .whenComplete(() {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentAccount = Map<String, dynamic>.from(account);
        isLoggedIn = true;
        selectedPageIndex = 0; // Go to Home
      });
    });
  }

  void _handleRegister(Map<String, dynamic> account) {
    setState(() {
      _accounts.add(Map<String, dynamic>.from(account));
    });
  }

  void _updateAccount(Map<String, dynamic> account) {
    int index = _accounts.indexWhere(
      (Map<String, dynamic> existing) => existing['email'] == account['email'],
    );
    if (index == -1) {
      return;
    }

    setState(() {
      _accounts[index] = Map<String, dynamic>.from(account);
      _currentAccount = _accounts[index];
    });
  }

  void _logout() {
    setState(() {
      isLoggedIn = false;
      selectedPageIndex = 2; // Go to Login page
      _currentAccount = null;
    });
  }

  List<Widget> _pages() {
    final Map<String, dynamic> fallbackAccount = <String, dynamic>{
      'email': '',
      'name': 'Guest',
      'password': '',
    };
    final String? ownerEmail = isLoggedIn
      ? (_currentAccount?['email'] as String?)
      : null;

    final Widget accountOrLogin = isLoggedIn
        ? AccountPage(
            fontSize: currentFontSize,
            account: _currentAccount ?? fallbackAccount,
            onUpdate: _updateAccount,
            onLogout: _logout,
          )
        : LoginPage(
            fontSize: currentFontSize,
            accounts: _accounts,
            onRegister: _handleRegister,
            onLoginSuccess: _handleLoginSuccess,
          );

    return <Widget>[
      HomePage(fontSize: currentFontSize, ownerEmail: ownerEmail),
      SettingsPage(
        fontSize: currentFontSize,
        onChanged: updateFontSize,
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: _updateThemeMode,
      ),
      accountOrLogin,
    ];
  }

  List<BottomNavigationBarItem> _navigationItems() {
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
      BottomNavigationBarItem(
        icon: Icon(isLoggedIn ? Icons.person : Icons.login),
        label: isLoggedIn ? 'Account' : 'Login',
      ),
    ];
  }

  ThemeData _buildTheme(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(height: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = _pages();
    final bool isDarkMode = _themeMode == ThemeMode.dark;
    final ThemeData lightTheme = _buildTheme(Brightness.light);
    final ThemeData darkTheme = _buildTheme(Brightness.dark);
    final ThemeData activeTheme = isDarkMode ? darkTheme : lightTheme;
    final ColorScheme scheme = activeTheme.colorScheme;
    final List<Color> gradientColors = isDarkMode
        ? [
            scheme.surface.withValues(alpha: 0.95),
            scheme.surface,
          ]
        : [
            scheme.primary.withValues(alpha: 0.08),
            scheme.secondary.withValues(alpha: 0.25),
          ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: ColoredBox(
        color: scheme.surface,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            appBar: AppBar(
              title: const Text("Medicine Ledger"),
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
            ),
            body: SafeArea(child: pages[selectedPageIndex]),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: scheme.surface.withValues(alpha: 0.95),
              selectedItemColor: scheme.primary,
              unselectedItemColor: scheme.onSurfaceVariant,
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
