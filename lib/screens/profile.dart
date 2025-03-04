import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> emotionalStates = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadEmotionalStates();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();

      setState(() {
        _username = userData['username'] ?? '';
        _email = userData['email'] ?? '';
        _weight = (userData['weight'] ?? 0).toString();
        _cigarettesPerDay = (userData['cigarettes_per_day'] ?? 0).toString();
        _packPrice = (userData['cost_per_pack'] ?? 0).toString();
        _gender = userData['gender'] ?? '';
        _dateOfBirth = (userData['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now();
      });
    }
  }

  Future<void> _loadEmotionalStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emotionalStates = prefs.getStringList('emotionalStates') ?? [];
    });
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildProfileInfo('Username:', _username),
                    _buildProfileInfo('Email:', _email),
                    _buildProfileInfo('Weight:', '$_weight kg'),
                    _buildProfileInfo('Cigarettes per Day:', _cigarettesPerDay),
                    _buildProfileInfo('Price per Pack:', '$_packPrice'),
                    _buildProfileInfo('Gender:', _gender),
                    _buildProfileInfo('Age:', '$age years'),
                    SizedBox(height: 20),
                    Divider(thickness: 2, color: Colors.blueAccent),
                    SizedBox(height: 20),
                    _buildEmotionalStatesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalStatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emotional States',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(15),
          child: _buildEmotionalStatesList(),
        ),
      ],
    );
  }

  Widget _buildEmotionalStatesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: emotionalStates.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Icon(
                  Icons.sentiment_satisfied,
                  color: Colors.blue.shade800,
                  size: 30,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    emotionalStates[index],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              color: Colors.blue.shade900,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
