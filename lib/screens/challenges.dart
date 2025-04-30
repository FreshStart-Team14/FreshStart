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
  int _weeklyGoal = 50;
  int _cigarettesPerDay = 0; // User's default daily consumption
  Map<String, int> _dailySmokingCounts = {};
  DateTime _lastUpdated = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChallengeData();
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
          _weeklyGoal =
              data['weeklyGoal'] ?? (_cigarettesPerDay * 7 * 0.7).floor();
          _lastUpdated = (data['lastUpdated'] as Timestamp).toDate();
          _dailySmokingCounts =
              smokingData.map((key, value) => MapEntry(key, value as int));
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

      await _firestore.collection('user_challenges').doc(userId).set(
          {
            'dailyGoal': _dailyGoal,
            'weeklyGoal': _weeklyGoal,
            'lastUpdated': Timestamp.now(),
            'dailySmokingCounts': smokingData,
          },
          SetOptions(
              merge:
                  true)); // Use merge option to prevent overwriting other fields
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
                    ),
                    _buildChallengeCard(
                      title: 'Weekly Challenge',
                      subtitle:
                          'Smoke less than $_weeklyGoal cigarettes this week',
                      current: weekSmoked,
                      goal: _weeklyGoal,
                      onTap: () => _showEditGoalDialog(false),
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
                              'Record Cigarette',
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
