import 'dart:ffi';

import 'package:flutter/cupertino.dart';
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

  double currentFontSize= 16;
  int pageNumber = 0;

  //Font size settings.
  void updateFontSize(double newSize)
  {
    setState(() {
      currentFontSize = newSize;
    });
  }


  @override
  Widget build(BuildContext context) {

    //Pages to switch between.
    List<Widget> myPages = [
       LoginPage(fontSize: currentFontSize),
       HomePage(fontSize: currentFontSize),
       SettingsPage(fontSize: currentFontSize, onChanged: updateFontSize),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Medicine Ledger"),
          backgroundColor: Colors.grey,
        ),

 backgroundColor: Colors.orangeAccent,

        body:myPages[pageNumber],
        bottomNavigationBar: BottomNavigationBar(

          currentIndex: pageNumber,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: 'Login',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
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
//        --   login page   --
class LoginPage extends StatefulWidget{
  final double fontSize;
  const LoginPage({super.key, required this.fontSize});
  State<LoginPage> createState() => LoginPageState();
}
class LoginPageState extends State<LoginPage>{

  Widget build(BuildContext context){

    return Scaffold(
     //   appBar:AppBar(title:Text("Login Page")),
      backgroundColor: Colors.grey,
        body:
        Center(child:
          SizedBox(
              width: 200,height:300,
            child:

            Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[

          TextFieldTapRegion(child: (TextField(
              decoration: InputDecoration(hintText: "Username",))),),
          TextFieldTapRegion(child: (TextField(
              decoration: InputDecoration(hintText: "Password"))),),

          ElevatedButton(
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content:Text("Login Successful")),
                );
        },

              child:Text("Login"),
          )]
            ),
          ),
        ),
    );
  }
}

// --- PAGE 2: HOME ---
class HomePage extends StatelessWidget {

  final double fontSize; //for font size settings.
  const HomePage({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Hello World (Home Page)', style: TextStyle(fontSize: 24)),
    );
  }
}

// --- PAGE 3: SETTINGS ---
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  required this.fontSize,
  required this.onChanged,});

  final double fontSize;
  final ValueChanged<double> onChanged;

  State<SettingsPage> createState() => SettingsPageState();
}
class SettingsPageState extends State<SettingsPage> {

  Widget build(BuildContext context) {
    return const Center(
      child:Column(children:

      [
        Text('Settings Menu', style: TextStyle(fontSize: 24)),

        DropdownMenu<double>
          (
            label:const Text("Font Size"),
            dropdownMenuEntries:const [
              DropdownMenuEntry(value: 16.0, label: "Small"),
              DropdownMenuEntry(value: 24.0, label: "Medium"),
              DropdownMenuEntry(value: 32.0, label: "Large"),
            ]
              ),
        ]
      )
    );
  }
}