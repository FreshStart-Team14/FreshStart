import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NonSmokingTrackerScreen extends StatefulWidget {
  @override
  _NonSmokingTrackerScreenState createState() =>
      _NonSmokingTrackerScreenState();
}

class _NonSmokingTrackerScreenState extends State<NonSmokingTrackerScreen>
    with SingleTickerProviderStateMixin {
  Map<DateTime, List<String>> _nonSmokingDays = {};
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _currentStreak = 0;
  int _totalXP = 0;
  int _level = 1;
  late AnimationController _buttonAnimationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadNonSmokingDays();
    _loadStreakData();

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _loadNonSmokingDays() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        List<String> savedDays =
            List<String>.from(snapshot.get('nonSmokingDays') ?? []);
        setState(() {
          _nonSmokingDays = {
            for (var day in savedDays) DateTime.parse(day): ['Non-Smoked']
          };
        });
      }
    } catch (e) {
      print('Error loading non-smoking days: $e');
    }
  }

  void _loadStreakData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        _currentStreak = snapshot.get('currentStreak') ?? 0;
        _totalXP = snapshot.get('totalXP') ?? 0;
        _level = snapshot.get('level') ?? 1;
        _checkForStreakReset();
      }
    } catch (e) {
      print('Error loading streak data: $e');
    }
  }

  void _checkForStreakReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastAddedDay = DateTime.parse(
        prefs.getString('lastAddedDay') ?? DateTime.now().toIso8601String());

    if (DateTime.now().difference(lastAddedDay).inDays > 1) {
      _currentStreak = 0;
      await prefs.setInt('currentStreak', _currentStreak);
    }
  }

  void _saveNonSmokingDay() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    _buttonAnimationController.forward();

    // Simulate a brief loading period
    await Future.delayed(const Duration(milliseconds: 500));

    String userId = FirebaseAuth.instance.currentUser!.uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDays = _nonSmokingDays.keys
        .map((e) => e.toIso8601String().split('T')[0])
        .toList();

    final todayString = DateTime.now().toIso8601String().split('T')[0];

    if (!savedDays.contains(todayString)) {
      savedDays.add(todayString);
      _nonSmokingDays[DateTime.now()] = ['Non-Smoked'];

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'nonSmokingDays': savedDays,
        });
        _updateStreakAndXP();
      } catch (e) {
        print('Error saving non-smoked day to Firestore: $e');
      }

      await prefs.setString('lastAddedDay', DateTime.now().toIso8601String());
    } else {
      Fluttertoast.showToast(
        msg: "This day is already marked.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _buttonAnimationController.reverse();
    setState(() {
      _isProcessing = false;
      _nonSmokingDays[DateTime.now()] = ['Non-Smoked'];
    });
  }

  void _updateStreakAndXP() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    _currentStreak++;

    int earnedXP =
        (_currentStreak % 15 == 0) ? (_currentStreak ~/ 15) * 500 : 0;
    _totalXP += earnedXP;
    _level = _calculateLevel(_totalXP);

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'currentStreak': _currentStreak,
        'totalXP': _totalXP,
        'level': _level,
        'lastAddedDay': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  int _calculateLevel(int xp) {
    int level = 1;
    int requiredXP = 500;

    while (level <= 150 && xp >= requiredXP) {
      xp -= requiredXP;
      level++;
      requiredXP += 500;
    }

    return level;
  }

  void _resetData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'currentStreak': 0,
        'totalXP': 0,
        'level': 1,
        'lastAddedDay': DateTime.now().toIso8601String(),
        'nonSmokingDays': [],
      });

      setState(() {
        _currentStreak = 0;
        _totalXP = 0;
        _level = 1;
        _nonSmokingDays.clear();
      });
    } catch (e) {
      print('Error resetting data in Firestore: $e');
    }
  }

  Widget _buildAnimatedButton() {
    return AnimatedBuilder(
      animation: _buttonAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 55,
            child: ElevatedButton(
              onPressed: _saveNonSmokingDay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: _isProcessing ? 2 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: _isProcessing ? 0 : 1,
                    child: Text(
                      'Add Non-Smoked Day',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: _isProcessing ? 1 : 0,
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.local_fire_department,
                label: 'Current Streak',
                value: '$_currentStreak days',
                color: Colors.orange,
              ),
              Container(
                  height: 40, width: 1, color: Colors.white.withOpacity(0.3)),
              _buildStatItem(
                icon: Icons.star,
                label: 'Level',
                value: '$_level',
                color: Colors.amber,
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.3), height: 30),
          _buildStatItem(
            icon: Icons.emoji_events,
            label: 'Total XP',
            value: '$_totalXP XP',
            color: Colors.greenAccent,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLarge = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isLarge ? 32 : 24),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: isLarge ? 16 : 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLarge ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: TableCalendar(
          focusedDay: _selectedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _calendarFormat = CalendarFormat.month;
            });
          },
          eventLoader: (day) => _nonSmokingDays[day] ?? [],
          calendarStyle: CalendarStyle(
            markersMaxCount: 1,
            markerDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Reset Progress'),
              content: Text(
                  'Are you sure you want to reset all your progress? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _resetData();
                    Navigator.pop(context);
                  },
                  child: Text('Reset', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        icon: Icon(Icons.refresh, color: Colors.red.withOpacity(0.8)),
        label: Text(
          'Reset Progress',
          style: TextStyle(color: Colors.red.withOpacity(0.8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Non-Smoking Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: _buildStatsCard(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    _buildCalendarCard(),
                    SizedBox(height: 20),
                    _buildAnimatedButton(),
                    _buildResetButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
