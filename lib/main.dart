import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double currentFontSize = 16;
  int pageNumber = 0;

  // Font size settings.
  void updateFontSize(double newSize) {
    setState(() {
      currentFontSize = newSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pages to switch between.
    List<Widget> myPages = [
      HomePage(fontSize: currentFontSize),
      SettingsPage(fontSize: currentFontSize, onChanged: updateFontSize),
      LoginPage(fontSize: currentFontSize),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Medicine Ledger"),
          backgroundColor: Colors.grey,
        ),
        backgroundColor: Colors.orangeAccent,
        body: myPages[pageNumber],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageNumber,
          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: 'Login',
            ),
          ],
          onTap: (int tappedIndex) {
            setState(() {
              pageNumber = tappedIndex;
            });
          },
        ),
      ),
    );
  }
}

// --- PAGE 1: LOGIN ---
class LoginPage extends StatefulWidget {
  final double fontSize;
  const LoginPage({super.key, required this.fontSize});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SizedBox(
          width: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use widget.fontSize for the title
              Text(
                "Login",
                style: TextStyle(
                  fontSize: widget.fontSize + 8, // Make title slightly larger
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: TextStyle(fontSize: widget.fontSize), // Apply font size to input text
                decoration: InputDecoration(
                  hintText: "Username",
                  hintStyle: TextStyle(fontSize: widget.fontSize), // Apply font size to hint
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                style: TextStyle(fontSize: widget.fontSize), // Apply font size to input text
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(fontSize: widget.fontSize), // Apply font size to hint
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Login Successful",
                        style: TextStyle(fontSize: widget.fontSize),
                      ),
                    ),
                  );
                },
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: widget.fontSize), // Apply font size to button text
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- PAGE 2: HOME ---
class HomePage extends StatelessWidget {
  final double fontSize;
  const HomePage({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Hello World (Home Page)',
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}

// --- PAGE 3: SETTINGS ---
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.fontSize,
    required this.onChanged,
  });

  final double fontSize;
  final ValueChanged<double> onChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Settings Menu',
            style: TextStyle(fontSize: widget.fontSize + 8, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DropdownMenu<double>(
            initialSelection: widget.fontSize,
            label: const Text("Font Size"),
            onSelected: (double? value) {
              if (value != null) {
                widget.onChanged(value);
              }
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 16.0, label: "Small"),
              DropdownMenuEntry(value: 24.0, label: "Medium"),
              DropdownMenuEntry(value: 32.0, label: "Large"),
            ],
          ),
        ],
      ),
    );
  }
}
