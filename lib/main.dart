import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freshstart/screens/dashboard.dart';
import 'package:freshstart/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Widget> getInitialScreen() async{
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null){
      return DashboardScreen();
    }
    else {
      return LoginScreen();
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshStart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<Widget>(
        future: getInitialScreen(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          else{
            return snapshot.data!;
          }
        },
      ),
      routes: {
        '/dashboard': (_) => DashboardScreen(),
        '/login': (_) => LoginScreen(),
      }, // Starting with the Login Screen
    );
  }
}

