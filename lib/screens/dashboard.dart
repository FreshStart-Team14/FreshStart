import 'package:flutter/material.dart';
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

class DashboardScreen extends StatelessWidget { //Stateless because dashboard is static 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FreshStart', style: TextStyle(fontWeight: FontWeight.bold)), //Title of the page
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout), //IconButton with logout to let user log out
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); //After log out action, firebase auth signs out user
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()), //User is navigated back to login screen
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Wrap GridView in SingleChildScrollView
        child: GridView.count(
          shrinkWrap: true, // Add this
          physics: NeverScrollableScrollPhysics(), // Add this
          crossAxisCount: 2, // Two items per row
          padding: EdgeInsets.all(15.0), //Spacing
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          children: <Widget>[
            _buildDashboardItem(context, 'How am I Today?', EmotionSelectionScreen(), Icons.mood),
            _buildDashboardItem(context, 'Non-Smoking Tracker', NonSmokingTrackerScreen(), Icons.check_circle),
            _buildDashboardItem(context, 'Weight Tracker', WeightTrackerScreen(), Icons.fitness_center),
            _buildDashboardItem(context, 'Saved Money', SavedMoneyScreen(), Icons.money),
            _buildDashboardItem(context, 'Non-Smoked Cigarettes', NonSmokedCigarettesScreen(), Icons.smoking_rooms),
            _buildDashboardItem(context, 'Personalized Diet Plans', DietPlansScreen(), Icons.restaurant),
            _buildDashboardItem(context, 'Profile', ProfileScreen(), Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, String title, Widget screen, IconData icon) { //To give action to each item on the dashboard and to give style to them
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen)); //On single tap user will be navigated to tapped "context" viewd
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // for rounded corners
        ),
        elevation: 5, // to add shadow
        child: Container(
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.blue.shade50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent), //To configure each icon
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
