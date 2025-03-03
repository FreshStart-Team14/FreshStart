/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _email = '';
  String _weight = '';
  String _cigarettesPerDay = '';
  String _packPrice = '';
  String _gender = '';
  DateTime _dateOfBirth = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      
      // Debugging: Print the data retrieved
      print('User Data: ${userData.data()}');

      setState(() {
        _username = userData['username'] ?? '';
        _email = userData['email'] ?? '';
        _weight = (userData['weight'] ?? 0).toString(); // Convert to string for display
        _cigarettesPerDay = (userData['cigarettes_per_day'] ?? 0).toString(); // Convert to string for display
        _packPrice = (userData['cost_per_pack'] ?? 0).toString(); // Convert to string for display
        _gender = userData['gender'] ?? '';
        _dateOfBirth = (userData['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now();
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    int age = _calculateAge(_dateOfBirth);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: $_username'),
            Text('Email: $_email'),
            Text('Weight: $_weight kg'),
            Text('Cigarettes per Day: $_cigarettesPerDay'),
            Text('Price per Pack: $_packPrice'),
            Text('Gender: $_gender'),
            Text('Age: $age years'),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _email = '';
  String _weight = '';
  String _cigarettesPerDay = '';
  String _packPrice = '';
  String _gender = '';
  DateTime _dateOfBirth = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();

      // Debugging: Print the data retrieved
      print('User Data: ${userData.data()}');

      setState(() {
        _username = userData['username'] ?? '';
        _email = userData['email'] ?? '';
        _weight = (userData['weight'] ?? 0).toString(); // Convert to string for display
        _cigarettesPerDay = (userData['cigarettes_per_day'] ?? 0).toString(); // Convert to string for display
        _packPrice = (userData['cost_per_pack'] ?? 0).toString(); // Convert to string for display
        _gender = userData['gender'] ?? '';
        _dateOfBirth = (userData['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now();
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    int age = _calculateAge(_dateOfBirth);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              //_buildProfileInfo('Username:', _username),
              _buildProfileInfo('Email:', _email),
              _buildProfileInfo('Weight:', '$_weight kg'),
              _buildProfileInfo('Cigarettes per Day:', _cigarettesPerDay),
              _buildProfileInfo('Price per Pack:', '$_packPrice'),
              _buildProfileInfo('Gender:', _gender),
              _buildProfileInfo('Age:', '$age years'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}