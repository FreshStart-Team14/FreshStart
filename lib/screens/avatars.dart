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
    'skeleton.png',
    'black_fedore_skeleton.jpg',
    'blue_fedore_skeleton.jpg',
    'chicken_hat_skeleton.jpg',
    'floral_skeleton.jpg',
    'eyeliner_skeleton.jpg',
    'golden_tooth_skeleton.jpg',
    'green_fedore_skeleton.jpg',
    'hat_skeleton.png',
    'green_hat_skeleton.jpg',
    'horse_head_skeleton.jpg',
    'pink_hat_skeleton.jpg',
    'red_glass_skeleton.jpg',
    'sunglasses_skeleton.png',
    'wizard_skeleton.png',
    'unhealthy_female.png',
    'unhealthy_male.png',
    'blue_hat&red_glass_unhealthy_male.jpg',
    'brown_fedore_unhealthy_male.jpg',
    'chicken_hat_unhealthy_male.jpg',
    'horse_head_unhealthy_male.jpg',
    'red_glass&brown_fedore_unhealthy_male.jpg',
    'red_glass_unhealthy_male.jpg',
    'green_hat_unhealthy_male.jpg',
    'brown_hair_black_top_unhealthy_female.png',
    'brown_hair_black_top_white_hat_unhealthy_female.png',
    'brown_hair_brown_top_white_hat_unhealthy_female.png',
    'brown_hair_pink_top_unhealthy_female.png',
    'brown_hair_pink_top_white_hat_unhealthy_female.png',
    'red_hair_brown_top_unhealthy_female.png',
    'red_hair_pink_top_unhealthy_female.png',
    'healthy_female.png',
    'healthy_male.png',
    'black_hair_blue_eyes_healthy_female.png',
    'black_hair_healthy_female.png',
    'black_healthy_female.png',
    'blonde_blue_eyes_healthy_female.png',
    'blonde_healthy_female.png',
    'blue_hair_healthy_female.png',
    'brown_hair_blue_eyes_healthy_female.png',
    'eyeliner_brown_hair_healthy_female.png',
    'ginger_hair_healthy_female.png',
    'pink_hair_healthy_female.png',
    'sunglasses_brown_hair_healhty_female.png',
    'brown_hair_sunglasses_healthy_male.png',
    'brown_hair_glasses_healthy_male.png',
    'black_hair_healthy_male.png',
    'blonde_healthy_male.png',
    'redhead_healthy_male.png',
    'bald_healthy_male.png',
    'beard_brown_hair_healthy_male.png',
    'mustache_brown_hair_healthy_male.png',
    'black_hair_beard_glasses_healthy_male.png',
    'blonde_beard_healthy_male.png',
    'black_healthy_male.png',
    'beard_black_healthy_male.png',
    'chicken_head_healthy_model.png',
    'horse_head_healthy_model.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Choose Your Avatar",
          style: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue[700]),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.star,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Level $userLevel",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Progress",
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Unlock new avatars as you level up!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: allAvatars.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final fileName = allAvatars[index];
                  final isAvailable = _isAvatarAvailable(fileName);
                  final isSelected =
                      selectedAvatar == 'assets/avatars/$fileName';
                  final levelRequired = _getUnlockLevel(fileName);

                  return GestureDetector(
                    onTap: isAvailable ? () => _selectAvatar(fileName) : null,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.blue : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: ColorFiltered(
                              colorFilter: isAvailable
                                  ? ColorFilter.mode(
                                      Colors.transparent, BlendMode.multiply)
                                  : ColorFilter.mode(
                                      Colors.black.withOpacity(0.6),
                                      BlendMode.darken),
                              child: Image.asset(
                                'assets/avatars/$fileName',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('❌ Failed to load: $fileName');
                                  return Container(
                                    color: Colors.grey[300],
                                    alignment: Alignment.center,
                                    child: Icon(Icons.broken_image,
                                        size: 36, color: Colors.red),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        if (!isAvailable)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock,
                                      color: Colors.white, size:24),
                                  SizedBox(height: 4),
                                  Text(
                                    "Level $levelRequired",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }}