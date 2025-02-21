import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freshstart/screens/create_account_screen.dart';
import 'package:freshstart/screens/forgot_password_screen.dart';
import 'package:freshstart/screens/register.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showAlertDialog('Error', 'Email and password are required.');
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password); //Firebase auth checks email format and incorrect fields
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DashboardScreen()));
    } catch (e) {
      _showAlertDialog('Error', e.toString());
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FreshStart Login',  style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton( // Button design to login
              onPressed: _login, //when pressed this method is launched
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor:Colors.blueAccent,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateAccountScreen()));
              },
              child: Text('Create an account'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent
              )
            ),
            TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
            },
            child: Text('Forgot Password?'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent
            ),
          ),
          ],
        ),
      ),
    );
  }
}
