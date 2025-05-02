import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvatarsScreen extends StatefulWidget {
  @override
  _AvatarsScreenState createState() => _AvatarsScreenState();
}

class _AvatarsScreenState extends State<AvatarsScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  int userLevel = 1;
  String? selectedAvatar;

  final List<String> allAvatars = [
  'black_fedora_skeleton.jpg',
  'blue_fedora_skeleton.jpg',
  'blue_hat_red_glass_unhealthy_male.jpg',
  'brown_fedora_unhealthy_male.jpg',
  'chicken_hat_skeleton.jpg',
  'chicken_hat_unhealthy_male.jpg',
  'eyeliner_skeleton.jpg',
  'floral_skeleton.jpg',
  'golden_tooth_skeleton.jpg',
  'green_fedora_skeleton.jpg',
  'green_hat_skeleton.jpg',
  'green_hat_unhealthy_male.jpg',
  'hat_skeleton.png',
  'horse_head_skeleton.jpg',
  'horse_head_unhealthy_male.jpg',
  'pink_hat_skeleton.jpg',
  'red_glass_brown_fedora_unhealthy_male.jpg',
  'red_glass_skeleton.jpg',
  'red_glass_unhealthy_male.jpg',
  'skeleton.png',
  'sunglasses_skeleton.png',
  'unhealthy_female.png',
  'unhealthy_male.png',
  'wizard_skeleton.png',
];


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        selectedAvatar = data['selectedAvatar'];
        userLevel = data['level'] ?? 1;
      });
    }
  }

  int _getUnlockLevel(String avatarName) {
    if (avatarName.contains('skeleton')) return 1;
    if (avatarName.contains('unhealthy')) return 6;
    if (avatarName.contains('healthy')) return 11;
    return 15;
  }

  bool _isAvatarAvailable(String avatarName) {
    int levelRequired = _getUnlockLevel(avatarName);
    return userLevel >= levelRequired && userLevel < levelRequired + 5;
  }

  Future<void> _selectAvatar(String avatarName) async {
    final String avatarPath = 'assets/avatars/$avatarName';
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
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: allAvatars.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final fileName = allAvatars[index];
            final isAvailable = _isAvatarAvailable(fileName);
            final isSelected = selectedAvatar == 'assets/avatars/$fileName';

            return GestureDetector(
              onTap: isAvailable ? () => _selectAvatar(fileName) : null,
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
                    child: AspectRatio(
  aspectRatio: 1, // forces square tiles
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: ColorFiltered(
      colorFilter: isAvailable
          ? ColorFilter.mode(Colors.transparent, BlendMode.multiply)
          : ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
      child: Image.asset(
        'assets/avatars/$fileName',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Failed to load: $fileName');
          return Container(
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: Icon(Icons.broken_image, size: 36, color: Colors.red),
          );
        },
      ),
    ),
  ),
),

                  ),
                  if (!isAvailable)
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
