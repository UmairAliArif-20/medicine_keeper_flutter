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

  int pageNumber = 0;

  @override
  Widget build(BuildContext context) {

    List<Widget> myPages = [
      const LoginPage(),
      const HomePage(),
      const SettingsPage(),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Medicine Ledger"),
          backgroundColor: Colors.grey,
        ),

 backgroundColor: Colors.transparent,

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
  const LoginPage({super.key});
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

          )
        ]
            ),
          ),


        ),
    );
  }
}

// --- PAGE 2: HOME ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Hello World (Home Page)', style: TextStyle(fontSize: 24)),
    );
  }
}

// --- PAGE 3: SETTINGS ---
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Menu', style: TextStyle(fontSize: 24)),
    );
  }
}