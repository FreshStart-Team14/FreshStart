import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _profileImage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _username = userData['username'] ?? '';
        _email = userData['email'] ?? '';
        _weight = (userData['weight'] ?? '').toString();
        _cigarettesPerDay = (userData['cigarettes_per_day'] ?? '').toString();
        _packPrice = (userData['cost_per_pack'] ?? '').toString();
        _gender = userData['gender'] ?? '';
        _dateOfBirth =
            (userData['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now();
      });
    }
  }

  Future<void> _updateUserField(String field, dynamic value) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({field: value});
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  void _editField(String fieldKey) async {
    if (fieldKey == 'dob') {
      final picked = await showDatePicker(
        context: context,
        initialDate: _dateOfBirth,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() {
          _dateOfBirth = picked;
        });
        await _updateUserField('dateOfBirth', picked);
      }
    } else {
      final controller = TextEditingController();
      String label = '';
      String hint = '';
      switch (fieldKey) {
        case 'weight':
          label = 'Enter Weight (kg)';
          hint = _weight;
          break;
        case 'cigarettes':
          label = 'Enter Cigarettes per Day';
          hint = _cigarettesPerDay;
          break;
        case 'packPrice':
          label = 'Enter Pack Price';
          hint = _packPrice;
          break;
      }

      controller.text = hint;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(label),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () async {
                final newValue = controller.text;
                Navigator.pop(context);

                setState(() {
                  if (fieldKey == 'weight') _weight = newValue;
                  if (fieldKey == 'cigarettes') _cigarettesPerDay = newValue;
                  if (fieldKey == 'packPrice') _packPrice = newValue;
                });

                String fieldName = fieldKey == 'weight'
                    ? 'weight'
                    : fieldKey == 'cigarettes'
                        ? 'cigarettes_per_day'
                        : 'cost_per_pack';

                await _updateUserField(fieldName, newValue);
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int age = _calculateAge(_dateOfBirth);

    return Scaffold(
      backgroundColor: Colors.blueAccent.shade700,
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _pickImage,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white24,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Text(
                            _username.isNotEmpty ? _username[0].toUpperCase() : '',
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          )
                        : null,
                  ),
                  SizedBox(height: 10),
                  Text(
                    _username,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _email,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildEditableStat('Weight', '$_weight kg', () => _editField('weight')),
            _buildEditableStat('Daily Cigarettes', _cigarettesPerDay, () => _editField('cigarettes')),
            _buildEditableStat('Pack Price', '\$$_packPrice', () => _editField('packPrice')),
            _buildEditableStat('Age', '$age years', () => _editField('dob')),
            SizedBox(height: 20),
            _buildInfoRow('Gender', _gender, Icons.person_rounded),
            SizedBox(height: 16),
            _buildInfoRow('Member Since', 'March 2024', Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableStat(String label, String value, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
              Text(value, style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: onTap,
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        )
      ],
    );
  }
}
