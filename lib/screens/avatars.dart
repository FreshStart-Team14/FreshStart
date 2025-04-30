import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarsScreen extends StatefulWidget {
  @override
  _AvatarsScreenState createState() => _AvatarsScreenState();
}

class _AvatarsScreenState extends State<AvatarsScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  int userLevel = 1;
  String? selectedAvatar;
  List<String> allAvatars = [];

  @override
  void initState() {
    super.initState();
    _loadUserLevelAndAvatar();
    _loadAvatars();
  }

  void _loadUserLevelAndAvatar() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        userLevel = data['level'] ?? 1;
        selectedAvatar = data['selectedAvatar'];
      });
    }
  }

  void _loadAvatars() {
    // Simulating asset file names
    allAvatars = [
      'black_fedore_skeleton.png',
      'blue_fedore_skeleton.png',
      'blue_hat&red_glass_unhealthy_male.png',
      'brown_fedore_unhealthy_male.png',
      'chicken_hat_skeleton.png',
      'chicken_hat_unhealthy_male.png',
      'eyeliner_skeleton.png',
      'floral_skeleton.png',
      'golden_tooth_skeleton.png',
      'green_fedore_skeleton.png',
      'green_hat_skeleton.png',
      'green_hat_unhealthy_male.png',
      'hat_skeleton.png',
      'horse_head_skeleton.png',
      'horse_head_unhealthy_male.png',
      'pink_hat_skeleton.png',
      'red_glass_brown_fedore_unhealthy_male.png',
      'red_glass_skeleton.png',
      'red_glass_unhealthy_male.png',
      'skeleton.png',
      'sunglasses_skeleton.png',
      'unhealthy_female.png',
      'unhealthy_male.png',
      'wizard_skeleton.png',
      // Add more filenames here...
    ];
  }

  int _getAvatarLevel(String filename) {
    if (filename.contains('skeleton')) return 1;
    if (filename.contains('unhealthy')) return 6;
    if (filename.contains('healthy')) return 11;
    return 15;
  }

  bool _isAvatarUnlocked(String filename) {
    int requiredLevel = _getAvatarLevel(filename);
    return userLevel >= requiredLevel && userLevel < requiredLevel + 5;
  }

  Future<void> _selectAvatar(String avatarPath) async {
    setState(() {
      selectedAvatar = avatarPath;
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'selectedAvatar': avatarPath,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Your Avatar"),
        backgroundColor: Colors.blueAccent.shade700,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: allAvatars.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final fileName = allAvatars[index];
            final isUnlocked = _isAvatarUnlocked(fileName);
            final isSelected = selectedAvatar == 'assets/avatars/$fileName';

            return GestureDetector(
              onTap: isUnlocked
                  ? () => _selectAvatar('assets/avatars/$fileName')
                  : null,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ColorFiltered(
                        colorFilter: isUnlocked
                            ? ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                        child: Image.asset(
                          'assets/avatars/$fileName',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (!isUnlocked)
                    Positioned.fill(
                      child: Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 30),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
