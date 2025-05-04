import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freshstart/screens/login_screen.dart';
import 'package:freshstart/screens/challenges.dart';
import 'package:freshstart/screens/emotion_tracker/emotion_selection_screen.dart';
import 'package:freshstart/screens/non_smoking_tracker.dart';
import 'package:freshstart/screens/weight_tracker.dart';
import 'package:freshstart/screens/saved_money.dart';
import 'package:freshstart/screens/non_smoked_cigarettes.dart';
import 'package:freshstart/screens/diet_plans.dart';
import 'package:freshstart/screens/profile.dart';
import 'package:freshstart/screens/community_screen.dart';
import 'package:freshstart/screens/freshagram.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final GlobalKey howAmIKey = GlobalKey();
  final GlobalKey nonSmokingKey = GlobalKey();
  final GlobalKey weightKey = GlobalKey();
  final GlobalKey savedMoneyKey = GlobalKey();
  final GlobalKey nonSmokedCigarettesKey = GlobalKey();
  final GlobalKey dietPlansKey = GlobalKey();
  final GlobalKey profileKey = GlobalKey();
  final GlobalKey challengesKey = GlobalKey();
  final GlobalKey communityKey = GlobalKey();
  final GlobalKey freshagramKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  List<TargetFocus> targets = [];
  late final AnimationController _controller;

  int calculatedLevel(int xp) {
    return (xp / 100).floor().clamp(1, 15);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _controller.forward();

    _checkForMaxLevel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  void _checkForMaxLevel() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data();
      final xp = data?['totalXP'] ?? 0;
      final level = calculatedLevel(xp);
      if (level == 15) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
Future<void> _startManualTutorial(String userId) async {
  for (final target in targets) {
    final context = target.keyTarget?.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      await Future.delayed(Duration(milliseconds: 300));

      final contentWidget = target.contents?.first.child ?? const SizedBox.shrink();
      bool dismissed = await _showSingleTutorialOverlay(context, contentWidget);
      if (!dismissed) break;
    }
  }

  await FirebaseFirestore.instance.collection('users').doc(userId).set(
    {'tutorialShown': true},
    SetOptions(merge: true),
  );
}


  Future<void> _checkAndShowTutorial() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final tutorialShown = userDoc.data()?['tutorialShown'] ?? false;

  if (!tutorialShown) {
    _createTutorialTargets();
    await _startManualTutorial(user.uid);
  }
}
Future<bool> _showSingleTutorialOverlay(BuildContext context, Widget content) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        backgroundColor: Colors.black87,
        content: content,
        actions: [
          TextButton(
            child: Text("NEXT", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: Text("SKIP", style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}


  void _createTutorialTargets() {
    targets = [
      _buildTarget(howAmIKey, "Track how you feel today!"),
      _buildTarget(nonSmokingKey, "Monitor your non-smoking streak!"),
      _buildTarget(weightKey, "Track your weight progress!"),
      _buildTarget(savedMoneyKey, "See how much money you saved!"),
      _buildTarget(nonSmokedCigarettesKey, "View the cigarettes you avoided!"),
      _buildTarget(dietPlansKey, "Get a diet based on your progress!"),
      _buildTarget(profileKey, "View and update your profile!"),
      _buildTarget(challengesKey, "Accept new challenges!"),
      _buildTarget(communityKey, "Join FreshAI Community!"),
      _buildTarget(freshagramKey, "Post and share your journey!"),
    ];
  }

  TargetFocus _buildTarget(GlobalKey key, String text) {
    return TargetFocus(
      identify: text,
      keyTarget: key,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final items = [
    _gridData("How am I Today?", EmotionSelectionScreen(), Icons.mood, howAmIKey),
    _gridData("Non-Smoking Tracker", NonSmokingTrackerScreen(), Icons.check_circle, nonSmokingKey),
    _gridData("Weight Tracker", WeightTrackerScreen(), Icons.fitness_center, weightKey),
    _gridData("Saved Money", SavedMoneyScreen(), Icons.money, savedMoneyKey),
    _gridData("Non-Smoked Cigarettes", NonSmokedCigarettesScreen(), Icons.smoking_rooms, nonSmokedCigarettesKey),
    _gridData("Diet Plans", DietPlansScreen(), Icons.restaurant, dietPlansKey),
    _gridData("Profile", ProfileScreen(), Icons.person, profileKey),
    _gridData("Challenges", ChallengesScreen(), Icons.track_changes, challengesKey),
    _gridData("FreshAI", CommunityScreen(), Icons.people, communityKey),
    _gridData("Freshagram", Freshagram(), Icons.chat_bubble, freshagramKey),
  ];

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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
          },
        )
      ],
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade100],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
            child: Text(
              'Welcome',
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
          Expanded(
            child: GridView.count(
              controller: _scrollController,
              crossAxisCount: 2,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
              childAspectRatio: 0.9,
              children: List.generate(items.length, (i) {
                final delay = i * 0.05;
                return SlideTransition(
                  position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
                      .animate(CurvedAnimation(parent: _controller, curve: Interval(delay, 1.0, curve: Curves.easeOut))),
                  child: items[i],
                );
              }),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _gridData(String title, Widget screen, IconData icon, Key key) {
  return GestureDetector(
    key: key,
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
              child: Icon(icon, size: 35, color: Colors.blue.shade800),
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