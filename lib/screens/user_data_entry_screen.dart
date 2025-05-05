import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class UserDataEntryScreen extends StatefulWidget {
  @override
  _UserDataEntryScreenState createState() => _UserDataEntryScreenState();
}

class _UserDataEntryScreenState extends State<UserDataEntryScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _cigarettesController = TextEditingController();
  final TextEditingController _packPriceController = TextEditingController();
  DateTime _dateOfBirth = DateTime.now();
  String _selectedGender = 'Male';

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final defaultDietPlan = {
  'breakfast': ["", ""],
  'lunch': ["", ""],
  'dinner': ["", ""],
  'snacks': ["", ""],
};


    if (_weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _cigarettesController.text.isEmpty ||
        _packPriceController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields.');
      return;
    }

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
  'username': FirebaseAuth.instance.currentUser!.displayName ?? '',
  'email': FirebaseAuth.instance.currentUser!.email,
  'weight': int.parse(_weightController.text),
  'height': int.parse(_heightController.text),
  'cigarettes_per_day': int.parse(_cigarettesController.text),
  'cost_per_pack': int.parse(_packPriceController.text),
  'gender': _selectedGender,
  'dateOfBirth': Timestamp.fromDate(_dateOfBirth),
  'tutorialShown': false,
  'dietPlan': defaultDietPlan,
});


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } catch (e) {
      _showErrorDialog('Failed to save data: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blueAccent.shade700,
                        Colors.blueAccent.shade100,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 60),
                          // Logo and Heading
                          Column(
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                size: 80,
                                color: Colors.white,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Enter Your Information',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _weightController,
                                  decoration: InputDecoration(
                                    labelText: 'Weight (kg)',
                                    prefixIcon: Icon(Icons.fitness_center),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 16),
                                TextField(
                                  controller: _heightController,
                                  decoration: InputDecoration(
                                    labelText: 'Height (cm)',
                                    prefixIcon: Icon(Icons.height),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 16),
                                TextField(
                                  controller: _cigarettesController,
                                  decoration: InputDecoration(
                                    labelText: 'Cigarettes per Day',
                                    prefixIcon: Icon(Icons.smoking_rooms),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 16),
                                TextField(
                                  controller: _packPriceController,
                                  decoration: InputDecoration(
                                    labelText: 'Price per Pack',
                                    prefixIcon: Icon(Icons.attach_money),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Select Date of Birth:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _selectDate(context),
                                  child: Text('${_dateOfBirth.toLocal()}'.split(' ')[0]),
                                ),
                                SizedBox(height: 20),
                                DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  items: ['Male', 'Female'].map((String value) {
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
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                                ElevatedButton(
                                  onPressed: _saveUserData,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: Size(double.infinity, 0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
