import 'package:flutter/material.dart';
import 'package:freshstart/screens/challenges.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:freshstart/screens/community_screen.dart'; 

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.eco_rounded, size: 32, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Fresh',
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
            Text(
              'Start',
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.0,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade100],
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 40.0),
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 15.0,
                children: <Widget>[
                  _buildDashboardItem(context, 'How am I Today?',
                      EmotionSelectionScreen(), Icons.mood),
                  _buildDashboardItem(context, 'Non-Smoking Tracker',
                      NonSmokingTrackerScreen(), Icons.check_circle),
                  _buildDashboardItem(context, 'Weight Tracker',
                      WeightTrackerScreen(), Icons.fitness_center),
                  _buildDashboardItem(
                      context, 'Saved Money', SavedMoneyScreen(), Icons.money),
                  _buildDashboardItem(context, 'Non-Smoked Cigarettes',
                      NonSmokedCigarettesScreen(), Icons.smoking_rooms),
                  _buildDashboardItem(context, 'Personalized Diet Plans',
                      DietPlansScreen(), Icons.restaurant),
                  _buildDashboardItem(
                      context, 'Profile', ProfileScreen(), Icons.person),
                  _buildDashboardItem(context, 'Challenges', ChallengesScreen(),
                      Icons.track_changes),
                  _buildDashboardItem(context, 'FreshAI',
                      CommunityScreen(), Icons.people), 
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context, String title, Widget screen, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 10,
        shadowColor: Colors.black38,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.shade100],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 35,
                  color: Colors.blue.shade800,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
