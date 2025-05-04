import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengesScreen extends StatefulWidget {
  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  int _dailyGoal = 10;
  int _weeklyGoal = 15;
  int _cigarettesPerDay = 0; // User's default daily consumption
  Map<String, int> _dailySmokingCounts = {};
  DateTime _lastUpdated = DateTime.now();
  bool _isLoading = false;
  bool hasCompletedDaily = false;
  bool hasCompletedWeekly = false;

  @override
  void initState() {
    super.initState();
    _loadChallengeData();
  }
  Future<void> _addXP(int xp) async {
  try {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      int currentXP = userDoc.data()?['totalXP'] ?? 0;
      int newXP = currentXP + xp;
      int newLevel = (newXP / 100).floor().clamp(1, 15);
      await _firestore.collection('users').doc(userId).update({
        'totalXP': newXP,
        'level': newLevel,
      });
    }
  } catch (e) {
    print('Error adding XP: $e');
  }
}
Future<void> _showXPPopup(int oldXP, int newXP, int level, int earnedXP) async {
  double startValue = (oldXP % 100) / 100;
  double endValue = (newXP % 100) / 100;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          earnedXP >= 0 ? 'XP Earned!' : 'XP Removed',
          style: TextStyle(color: earnedXP >= 0 ? Colors.blue : Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${earnedXP > 0 ? '+' : ''}$earnedXP XP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: earnedXP >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: startValue, end: endValue),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                );
              },
            ),
            const SizedBox(height: 12),
            Text('Level $level', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
    },
  );
}

Future<void> _addXPWithPopup(int xpChange) async {
  try {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return;
    int _getLevelFromXP(int xp) {
  return (xp ~/ 100 + 1).clamp(1, 15);
}

    int currentXP = userDoc.data()?['totalXP'] ?? 0;
    int currentLevel = _getLevelFromXP(currentXP);

    int updatedXP = (currentXP + xpChange).clamp(0, double.infinity).toInt();
    int updatedLevel = _getLevelFromXP(updatedXP);

    if (xpChange == 0 || updatedXP == currentXP) return;

    await _firestore.collection('users').doc(userId).update({
      'totalXP': updatedXP,
      'level': updatedLevel,
    });

    await _showXPPopup(currentXP, updatedXP, updatedLevel, xpChange);

    // 🔥 Level-up confirmation
    if (updatedLevel > currentLevel) {
      await _showLevelUpPopup(updatedLevel);
    }
  } catch (e) {
    print('❌ Error updating XP: $e');
  }
}

Future<void> _showLevelUpPopup(int level) async {
  await Future.delayed(Duration(milliseconds: 300)); // optional delay after XP dialog

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Text(
            'Level Up!',
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🎉 Congratulations!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'ve reached Level $level.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Awesome!', style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}



  Future<void> _loadChallengeData() async {
    if (userId.isEmpty) return;

    try {
      // Load user's default cigarettes per day
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _cigarettesPerDay = userData['cigarettes_per_day'] ?? 0;
      }

      // Load challenge goals and smoking history
      final challengeDoc =
          await _firestore.collection('user_challenges').doc(userId).get();
      if (challengeDoc.exists) {
        final data = challengeDoc.data() as Map<String, dynamic>;
        final smokingData =
            data['dailySmokingCounts'] as Map<String, dynamic>? ?? {};

        setState(() {
  _dailyGoal = data['dailyGoal'] ?? (_cigarettesPerDay * 0.7).floor();
  _weeklyGoal = data['weeklyGoal'] ?? (_cigarettesPerDay * 7 * 0.7).floor();
  _lastUpdated = (data['lastUpdated'] as Timestamp).toDate();
  _dailySmokingCounts = smokingData.map((key, value) => MapEntry(key, value as int));
  hasCompletedDaily = data['hasCompletedDaily'] ?? false;
  hasCompletedWeekly = data['hasCompletedWeekly'] ?? false;
});

      } else {
        // Set initial goals to 70% of current consumption
        setState(() {
          _dailyGoal = (_cigarettesPerDay * 0.7).floor();
          _weeklyGoal = (_cigarettesPerDay * 7 * 0.7).floor();
          _saveChallengeData();
        });
      }
    } catch (e) {
      print('Error loading challenge data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading challenge data. Please try again.')),
      );
    }
  }

  Future<void> _saveChallengeData() async {
    if (userId.isEmpty) return;

    try {
      // Convert the Map<String, int> to a format Firestore can handle
      Map<String, dynamic> smokingData = {};
      _dailySmokingCounts.forEach((key, value) {
        smokingData[key] = value;
      });

      await _firestore.collection('user_challenges').doc(userId).set({
  'dailyGoal': _dailyGoal,
  'weeklyGoal': _weeklyGoal,
  'lastUpdated': Timestamp.now(),
  'dailySmokingCounts': smokingData,
  'hasCompletedDaily': hasCompletedDaily,
  'hasCompletedWeekly': hasCompletedWeekly,
}, SetOptions(merge: true));

          SetOptions(
              merge:
                  true); // Use merge option to prevent overwriting other fields
    } catch (e) {
      print('Error saving challenge data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error saving challenge data. Please try again.')),
      );
    }
  }

  Future<void> _recordSmoke() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      setState(() {
        _dailySmokingCounts[today] = (_dailySmokingCounts[today] ?? 0) + 1;
      });
      await _saveChallengeData();
    } catch (e) {
      print('Error recording smoke: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording cigarette. Please try again.')),
      );
    }
  }

  int _getTodaySmoked() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _dailySmokingCounts[today] ?? 0;
  }

  int _getWeekSmoked() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = now.add(Duration(days: 1));

    int total = 0;
    _dailySmokingCounts.forEach((dateStr, count) {
      final date = DateTime.parse(dateStr);
      if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
        total += count;
      }
    });
    return total;
  }

  // Helper method to get color based on progress
  Color _getProgressColor(int current, int goal) {
    if (current == 0) return Colors.green;
    if (current >= goal) return Colors.red;

    // Calculate how close we are to the goal (0.0 to 1.0)
    double progress = current / goal;

    // Create a color gradient from green to yellow to red
    if (progress <= 0.5) {
      // Blend from green to yellow
      return Color.lerp(
        Colors.green,
        Colors.orange,
        progress * 2,
      )!;
    } else {
      // Blend from yellow to red
      return Color.lerp(
        Colors.orange,
        Colors.red,
        (progress - 0.5) * 2,
      )!;
    }
  }

  Widget _buildChallengeCard({
    required String title,
    required String subtitle,
    required int current,
    required int goal,
    required VoidCallback onTap,
    required bool isCompleted,
    required VoidCallback onComplete,
    required VoidCallback onUndo,
  }) {
    final isFailed = current > goal;
    final progressColor = _getProgressColor(current, goal);
    final remaining = goal - current;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            current == 0
                                ? Icons.check_circle
                                : (isFailed
                                    ? Icons.warning
                                    : Icons.smoking_rooms),
                            color: progressColor,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            current == 0
                                ? 'Perfect!'
                                : isFailed
                                    ? 'Exceeded'
                                    : '$remaining left',
                            style: TextStyle(
                              color: progressColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (current / goal).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(progressColor),
                    minHeight: 6,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: (isCompleted || isFailed) ? null : onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? Colors.grey : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isCompleted ? "Completed" : "I Completed the Challenge"),
                    ),
                    if (isCompleted)
                      TextButton(
                        onPressed: onUndo,
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text("Undo"),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditGoalDialog(bool isDaily) {
    final defaultGoal = isDaily
        ? (_cigarettesPerDay * 0.7).floor()
        : (_cigarettesPerDay * 7 * 0.7).floor();

    final controller = TextEditingController(
      text: (isDaily ? _dailyGoal : _weeklyGoal).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Edit ${isDaily ? "Daily" : "Weekly"} Goal',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current consumption: $_cigarettesPerDay cigarettes per day',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Recommended goal: $defaultGoal cigarettes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[600],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target cigarettes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                setState(() {
                  if (isDaily) {
                    _dailyGoal = newGoal;
                  } else {
                    _weeklyGoal = newGoal;
                  }
                });
                await _saveChallengeData();
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todaySmoked = _getTodaySmoked();
    final weekSmoked = _getWeekSmoked();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.blue, size: 24),
            SizedBox(width: 8),
            Text(
              'Challenges',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChallengeCard(
  title: 'Daily Challenge',
  subtitle: 'Smoke less than $_dailyGoal cigarettes today',
  current: todaySmoked,
  goal: _dailyGoal,
  onTap: () => _showEditGoalDialog(true),
  isCompleted: hasCompletedDaily,
  onComplete: () async {
  setState(() => hasCompletedDaily = true);
  await _saveChallengeData();
  await _addXPWithPopup(10);
},
onUndo: () async {
  setState(() => hasCompletedDaily = false);
  await _saveChallengeData();
  await _addXPWithPopup(-10);
},

),

                    _buildChallengeCard(
                      title: 'Weekly Challenge',
                      subtitle:
                          'Smoke less than $_weeklyGoal cigarettes this week',
                      current: weekSmoked,
                      goal: _weeklyGoal,
                      onTap: () => _showEditGoalDialog(false),
                      isCompleted: hasCompletedWeekly,
                      onComplete: () async {
  setState(() => hasCompletedWeekly = true);
  await _saveChallengeData();
  await _addXPWithPopup(15);
},
onUndo: () async {
  setState(() => hasCompletedWeekly = false);
  await _saveChallengeData();
  await _addXPWithPopup(-15);
},

                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _recordSmoke,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.smoking_rooms),
                            SizedBox(width: 8),
                            Text(
                              'I Smoked a Cigarette',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
