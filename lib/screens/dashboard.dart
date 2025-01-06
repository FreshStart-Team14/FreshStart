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

class DashboardScreen extends StatelessWidget { //Stateless because dashboard is static 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FreshStart Dashboard'), //Title of the page
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
      body: GridView.count( //Grid structure of the dashboard
        crossAxisCount: 2, // Two items per row
        padding: EdgeInsets.all(10.0), //Spacing
        children: <Widget>[
          _buildDashboardItem(context, 'Non-Smoking Tracker', NonSmokingTrackerScreen()),
          _buildDashboardItem(context, 'Weight Tracker', WeightTrackerScreen()),
          _buildDashboardItem(context, 'Saved Money', SavedMoneyScreen()),
          _buildDashboardItem(context, 'Non-Smoked Cigarettes', NonSmokedCigarettesScreen()),
          _buildDashboardItem(context, 'Personalized Diet Plans', DietPlansScreen()),
          _buildDashboardItem(context, 'Profile', ProfileScreen()),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, String title, Widget screen) { //To give action to each item on the dashboard 
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen)); //On single tap user will be navigated to tapped "context" viewd
      },
      child: Card(
        child: Center(
          child: Text(title, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
