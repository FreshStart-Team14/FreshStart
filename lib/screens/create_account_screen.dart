import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data_entry_screen.dart'; 

class CreateAccountScreen extends StatefulWidget { //To set account creation interface
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState(); //To manage the state of the screen, inputs and firebase
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(); //Defines text fields controllers for mail, password and username

  final FirebaseAuth _auth = FirebaseAuth.instance; //Defines firebase auth

  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Defines firebase db

  Future<void> createAccount() async { //This method is called when create account button is clicked
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword( //createUserWithEmailAndPassword Automatically checks mail format and etc. 
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ); //Creates and saves user account to firebase by using mail and password
      
      await _firestore.collection('users').doc(userCredential.user!.uid).set({ //Creates a user document in collection of firebase, uses unique user id
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
          builder: (context) => UserDataEntryScreen(), //After succesful account creation, navigates to user_data_entry_screen
        ),
      );


    } catch (e) { //Error Handling part, error message will be displayed
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
  Widget build(BuildContext context) { //User Interface
    return Scaffold(
      appBar: AppBar(title: Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)), //Title of the screen is displayed
      backgroundColor: Colors.blueAccent,),
      body: Padding(
        padding: EdgeInsets.all(16.0), //To give proper spacing
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'), //Textfields to get user input
              obscureText: true, //Hides password for the security
            ),
            SizedBox(height: 20),
            ElevatedButton( // Button design to save weight
              onPressed: createAccount, //when pressed this method is launched
              child: Text('Create Account',),
              style: ElevatedButton.styleFrom(
                backgroundColor:Colors.blueAccent,
                textStyle: TextStyle(fontSize: 14),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
