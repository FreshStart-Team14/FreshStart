import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data_entry_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  //To set account creation interface
  @override
  _CreateAccountScreenState createState() =>
      _CreateAccountScreenState(); //To manage the state of the screen, inputs and firebase
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController =
      TextEditingController(); //Defines text fields controllers for mail, password and username

  final FirebaseAuth _auth = FirebaseAuth.instance; //Defines firebase auth

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Defines firebase db

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> createAccount() async {
    //This method is called when create account button is clicked
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        //createUserWithEmailAndPassword Automatically checks mail format and etc.
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ); //Creates and saves user account to firebase by using mail and password

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        //Creates a user document in collection of firebase, uses unique user id
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'weight': null,
        'height': null,
        'age': null,
        'cigarettes_per_day': null,
        'cost_per_pack': null,
        'date_of_birth': null,
      }); //Stores above user data

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              UserDataEntryScreen(), //After succesful account creation, navigates to user_data_entry_screen
        ),
      );
    } catch (e) {
      //Error Handling part, error message will be displayed
      print(e);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height:
            MediaQuery.of(context).size.height, // Added to ensure full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade100],
          ),
        ),
        child: SafeArea(
          bottom: false, // Removes bottom safe area
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(), // Prevents overscroll glow effect
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 40),
                  Text(
                    'Create\nYour Account',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.white, // Changed to white for better contrast
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12), // Smaller spacing
                  Text(
                    'Welcome to the team! Let\'s begin your smoke-free journey together.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            await createAccount();
                            setState(() => _isLoading = false);
                          },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.white, // Changed to white
                          fontSize: 16, // Increased font size
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white, // Changed to white
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // Increased font size
                            decoration:
                                TextDecoration.underline, // Added underline
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24), // Added extra padding at bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
