import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freshstart/screens/avatars.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';


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
  String _profileImageUrl = '';


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
        _profileImageUrl = userData['profile_image'] ?? '';

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
Future<void> requestStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    // Permission granted
  } else {
    // Handle the case when permission is denied
  }
}
  Future<void> _pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile == null) return;

  setState(() {
    _profileImage = File(pickedFile.path);
  });

  final user = _auth.currentUser;
  if (user != null) {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      await storageRef.putFile(_profileImage!);
      final downloadUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'profile_image': downloadUrl,
      });

      setState(() {
        _profileImageUrl = downloadUrl;
      });

      print('✅ Profile image uploaded and saved.');
    } on FirebaseException catch (e) {
      print('❌ FirebaseException: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.message}')),
      );
    } catch (e) {
      print('❌ General exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during upload.')),
      );
    }
  }
}







  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_rounded,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Profile',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Maintain layout balance
          SizedBox(width: 48),
        ],
      ),
      body: Stack(
        children: [
          // Watermark background
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[100]!,
                    Colors.grey[100]!.withOpacity(0.8),
                    Colors.grey[100]!.withOpacity(0.6),
                    Colors.grey[100]!.withOpacity(0.4),
                  ],
                  stops: const [0.0, 0.2, 0.4, 0.6],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Opacity(
                opacity: 0.1,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 120,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
  padding: EdgeInsets.all(20),
  child: Column(
    children: [
      // Profile Picture Section
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: _profileImage != null
    ? FileImage(_profileImage!)
    : (_profileImageUrl.isNotEmpty ? NetworkImage(_profileImageUrl) : null) as ImageProvider?,

                    child: _profileImage == null
                        ? Text(
                            _username.isNotEmpty
                                ? _username[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.blue.shade700,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              _username,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _email,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),

      // Stats Section
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildEditableStat('Weight', '$_weight kg', null),
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            _buildEditableStat('Daily Cigarettes', _cigarettesPerDay, () => _editField('cigarettes')),
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            _buildEditableStat('Pack Price', '\$$_packPrice', () => _editField('packPrice')),
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            _buildEditableStat('Age', '$age years', () => _editField('dob')),
          ],
        ),
      ),
      SizedBox(height: 20),

      // Info Section
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 20),

      // 🔵 Avatars Button
      ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AvatarsScreen()),
          );
        },
        icon: Icon(Icons.image, color: Colors.white),
        label: Text('Avatars & Skins'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
SizedBox(height: 16),
_buildInfoRow('Gender', _gender, Icons.person_rounded),
SizedBox(height: 16),
_buildInfoRow('Member Since', 'March 2024', Icons.calendar_today),

          ],
        ),
      ),
      
    ],
  ),
),

        ],
      ),
    );
  }

  Widget _buildEditableStat(String label, String value, VoidCallback? onTap) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (onTap != null)
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: onTap,
          ),
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
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }
}
