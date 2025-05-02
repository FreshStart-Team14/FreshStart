import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:freshstart/screens/challenges.dart' as challenges;
import 'package:freshstart/screens/non_smoking_tracker.dart';
import 'package:freshstart/screens/weight_tracker.dart';
import 'package:freshstart/screens/saved_money.dart';
import 'package:freshstart/screens/non_smoked_cigarettes.dart';
import 'package:freshstart/screens/diet_plans.dart';
import 'package:freshstart/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freshstart/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freshstart/screens/emotion_tracker/emotion_selection_screen.dart';
import 'package:freshstart/screens/community_screen.dart';
import 'package:freshstart/screens/freshagram.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  int calculatedLevel(int xp){
      return (xp / 100).floor().clamp(1,15);
    }
  @override
  void initState(){
    super.initState();
    _checkForMaxLevel();
  }
  void _checkForMaxLevel() async{
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists){
      final data = doc.data();
      final xp = data?['totalXP'] ?? 0;
      final level = calculatedLevel(xp);
      if (level == 15){
        WidgetsBinding.instance.addPostFrameCallback((_){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Congratulations! You have reached the Max Level (15)!'),
              backgroundColor: Colors.green.shade700,
              duration: Duration(seconds: 4),
            ),
          );
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFFB3D1FF);
    final Color appBarColor = Colors.white;
    final Color logoColor = Colors.blueAccent.shade700;
    final Color titleColor = Colors.blue;
    final Color subtitleColor = Colors.blue.withOpacity(0.8);
    final Color welcomeColor = Colors.blue.shade900;
    final Color cardColor = Colors.white;
    final Color cardShadow = Colors.black.withOpacity(0.07);
    final Color iconBg = Colors.blue.shade50;
    final Color iconColor = Colors.blue;
    final Color textColor = Colors.blue.shade900;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.8),
                backgroundColor,
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: null,
            title: Row(
              children: [
                Icon(Icons.eco_rounded, size: 32, color: logoColor),
                SizedBox(width: 12),
                Text(
                  'Fresh',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: titleColor,
                  ),
                ),
                Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.0,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.blue),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            // Watermark background
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor,
                      backgroundColor.withOpacity(0.8),
                      backgroundColor.withOpacity(0.6),
                      backgroundColor.withOpacity(0.4),
                    ],
                    stops: const [0.0, 0.2, 0.4, 0.6],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.08,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          size: 120,
                          color: logoColor.withOpacity(0.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'FreshStart',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: logoColor.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
                  child: Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: welcomeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.6,
                      children: <Widget>[
                        _buildDashboardItem(
                            context,
                            'How am I Today?',
                            EmotionSelectionScreen(),
                            Icons.mood,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                        _buildDashboardItem(
                            context,
                            'Non-Smoking Tracker',
                            NonSmokingTrackerScreen(),
                            Icons.check_circle,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                        _buildDashboardItem(
                            context,
                            'Weight Tracker',
                            WeightTrackerScreen(),
                            Icons.fitness_center,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                        _buildDashboardItem(
                            context,
                            'Saved Money',
                            SavedMoneyScreen(),
                            Icons.money,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                        _buildDashboardItem(
                            context,
                            'Non-Smoked Cigarettes',
                            NonSmokedCigarettesScreen(),
                            Icons.smoking_rooms,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                        _buildDashboardItem(
                            context,
                            'Personalized Diet Plans',
                            DietPlansScreen(),
                            Icons.restaurant,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                        _buildDashboardItem(
                            context,
                            'Profile',
                            ProfileScreen(),
                            Icons.person,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                        _buildDashboardItem(
                            context,
                            'Challenges',
                            challenges.ChallengesScreen(),
                            Icons.track_changes,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                        _buildDashboardItem(
                            context,
                            'FreshAI',
                            CommunityScreen(),
                            Icons.people,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                        _buildDashboardItem(
                            context,
                            'Freshagram',
                            Freshagram(),
                            Icons.chat_bubble,
                            cardColor,
                            cardShadow,
                            iconBg,
                            iconColor,
                            textColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context,
      String title,
      Widget screen,
      IconData icon,
      Color cardColor,
      Color cardShadow,
      Color iconBg,
      Color iconColor,
      Color textColor) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconBg.withOpacity(0.3),
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 350),
                  child: Icon(
                    icon,
                    size: 22,
                    color: iconColor,
                    key: ValueKey(iconColor),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 350),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                  child: Text(title, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
