import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class UserDataEntryScreen extends StatefulWidget { //To set user data entry screen interface
  @override
  _UserDataEntryScreenState createState() => _UserDataEntryScreenState(); //To manage the state of the screen
}

class _UserDataEntryScreenState extends State<UserDataEntryScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  //final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cigarettesController = TextEditingController();
  final TextEditingController _packPriceController = TextEditingController(); //To get inputs from the user 

  DateTime _dateOfBirth = DateTime.now();
  String _selectedGender = 'Male'; // Default gender value

  Future<void> _saveUserData() async { //This method is called to save the user under the collection
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _cigarettesController.text.isEmpty ||
        _packPriceController.text.isEmpty 
        //||_ageController.text.isEmpty
        ) {
      _showErrorDialog('Please fill in all fields.'); //Checks if any field is empty and gives message according to that
      return; 
    }

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid; //Gets the current user's id from the firbase auth

      
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': FirebaseAuth.instance.currentUser!.displayName ?? '', 
        'email': FirebaseAuth.instance.currentUser!.email, 
        'weight': int.parse(_weightController.text), 
        'height': int.parse(_heightController.text), 
        //'age': int.parse(_ageController.text), 
        'cigarettes_per_day': int.parse(_cigarettesController.text), 
        'cost_per_pack': int.parse(_packPriceController.text), 
        'gender': _selectedGender,
        'dateOfBirth': Timestamp.fromDate(_dateOfBirth), //Saves user inputs to firebase
        'tutorialShown': false,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()), //If there is no problem user is navigated to dashboard screen
      );
    } catch (e) {
      _showErrorDialog('Failed to save data: $e'); //Message in case there is any error
    }
  }

  void _showErrorDialog(String message) { //Error message to be displayed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async { //Allows users to select birthdates from the calendar widget
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() { //Immediately selected date will be displayed on the calendar thats why setState is used.
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) { //For the user interface
    return Scaffold(
      appBar: AppBar(title: Text('Enter Your Information', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.blueAccent), //Title of the screen
      body: Padding(
        padding: EdgeInsets.all(16.0), //Spacing
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: 'Weight(kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(labelText: 'Height(cm)'),
              keyboardType: TextInputType.number,
            ),
            /*TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),*/
            TextField(
              controller: _cigarettesController,
              decoration: InputDecoration(labelText: 'Cigarettes You Consume per Day'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _packPriceController,
              decoration: InputDecoration(labelText: 'Price of One Pack'), //Textfields to get inputs
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Text('Select Date of Birth:'),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text('${_dateOfBirth.toLocal()}'.split(' ')[0]), //Selection of birthdate part
            ),
            SizedBox(height: 20),
            DropdownButton<String>( //Gender selection dropdown 
              value: _selectedGender,
              items: <String>['Male', 'Female'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton( // Button design to login
              onPressed: _saveUserData, //when pressed this method is launched
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor:Colors.blueAccent,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
