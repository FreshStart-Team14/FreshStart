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
    _loadStreakData();
    _loadNonSmokingDays().then((_) => _checkForStreakReset());
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
Future<void> _showLevelUpPopup(int level) async {
  await Future.delayed(Duration(milliseconds: 300)); // Smooth delay after XP popup

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.amber, size: 28),
          SizedBox(width: 8),
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
          Text(
            '🎉 Congratulations!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Text(
            'You\'ve reached Level $level.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Awesome!',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}

Future<void> _loadNonSmokingDays() async {
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
  DateTime? lastAddedDate;
  try {
    lastAddedDate = DateTime.parse(prefs.getString('lastAddedDay') ?? '');
  } catch (_) {
    lastAddedDate = null;
  }

  final now = DateTime.now();
  final yesterday = DateTime(now.year, now.month, now.day - 1);

  // Check if yesterday is marked
  final isYesterdayMarked = _nonSmokingDays.keys.any((date) =>
    date.year == yesterday.year &&
    date.month == yesterday.month &&
    date.day == yesterday.day
  );

  if (!isYesterdayMarked) {
    _currentStreak = 0;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'currentStreak': _currentStreak});

    await prefs.setInt('currentStreak', _currentStreak);
  }
}


  void _saveNonSmokingDay() async {
  if (_isProcessing) return;
  final now = DateTime.now();
if (_selectedDay.year != now.year ||
    _selectedDay.month != now.month ||
    _selectedDay.day != now.day) {
  Fluttertoast.showToast(
    msg: "Only today's date can be marked.",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
  _buttonAnimationController.reverse();
  setState(() => _isProcessing = false);
  return;
}

  setState(() => _isProcessing = true);
  _buttonAnimationController.forward();
  await Future.delayed(const Duration(milliseconds: 500));

  String userId = FirebaseAuth.instance.currentUser!.uid;
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final selectedStr = _selectedDay.toIso8601String().split('T')[0]; // Date in YYYY-MM-DD format
  List<String> savedDays = _nonSmokingDays.keys
      .map((e) => e.toIso8601String().split('T')[0]) // Get date part only
      .toList();

  if (savedDays.contains(selectedStr)) {
    Fluttertoast.showToast(
      msg: "This date is already marked as non-smoked.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    
    _buttonAnimationController.reverse();
    setState(() => _isProcessing = false);
    return;
  }
  if (_selectedDay.isAfter(DateTime.now())) {
  Fluttertoast.showToast(
    msg: "You can't mark a future date.",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
  _buttonAnimationController.reverse();
  setState(() => _isProcessing = false);
  return;
}

  savedDays.add(selectedStr);
  _nonSmokingDays[_selectedDay] = ['Non-Smoked'];

  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'nonSmokingDays': savedDays,
    });

    await prefs.setString('lastAddedDay', DateTime.now().toIso8601String());

    _updateStreakAndXP(); // Still use one-day logic
  } catch (e) {
    print('Error saving selected non-smoked day: $e');
  }
  
  await Future.delayed(const Duration(milliseconds: 500));
  _buttonAnimationController.reverse();
  setState(() => _isProcessing = false);
}


  Future<void> _updateStreakAndXP() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  _currentStreak++;
  int earnedXP = 20;
  int oldXP = _totalXP;
  int oldLevel = _level;
  int newXP = oldXP + earnedXP;
  int newLevel = _calculateLevel(newXP);
  if (_currentStreak % 15 == 0) {
    earnedXP += (_currentStreak ~/ 15) * 500;
  }


  setState(() {
  _totalXP = newXP;
  _level = newLevel;
});

await FirebaseFirestore.instance.collection('users').doc(userId).update({
  'currentStreak': _currentStreak,
  'totalXP': newXP,
  'level': newLevel,
  'lastAddedDay': DateTime.now().toIso8601String(),
});

await _showXPPopup(oldXP, newXP, newLevel, earnedXP);

// ✅ If user leveled up, show congrats popup
if (newLevel > oldLevel) {
  await _showLevelUpPopup(newLevel);
}

}
Future<void> _showXPPopup(int oldXP, int newXP, int level, int earnedXP) async {
  final start = (oldXP % 500) / 500;
  final end = (newXP % 500) / 500;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'XP Gained!',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+$earnedXP XP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              duration: Duration(seconds: 2),
              tween: Tween(begin: start, end: end),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                );
              },
            ),
            SizedBox(height: 12),
            Text('Level $level', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Close', style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
    },
  );
}


  int _calculateLevel(int totalXP) {
  return (totalXP ~/ 100 + 1).clamp(1, 15);
}


  void _resetData() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final todayString = DateTime.now().toIso8601String().split('T')[0];

  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return;

    List<String> savedDays = List<String>.from(userDoc.data()?['nonSmokingDays'] ?? []);
    int currentStreak = userDoc.data()?['currentStreak'] ?? 0;
    int totalXP = userDoc.data()?['totalXP'] ?? 0;
    int level = userDoc.data()?['level'] ?? 1;

    if (!savedDays.contains(todayString)) {
      Fluttertoast.showToast(
        msg: "Today hasn't been marked as non-smoked.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    savedDays.remove(todayString);
    int xpToSubtract = 20;
    if ((currentStreak % 15 == 0) && currentStreak != 0) {
      xpToSubtract += (currentStreak ~/ 15) * 500;
    }

    int updatedXP = (totalXP - xpToSubtract).clamp(0, double.infinity).toInt();
    int updatedStreak = (currentStreak - 1).clamp(0, double.infinity).toInt();
    int updatedLevel = _calculateLevel(updatedXP);

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'nonSmokingDays': savedDays,
      'currentStreak': updatedStreak,
      'totalXP': updatedXP,
      'level': updatedLevel,
    });

    setState(() {
      _nonSmokingDays.removeWhere((date, _) =>
          date.toIso8601String().split('T')[0] == todayString);
      _currentStreak = updatedStreak;
      _totalXP = updatedXP;
      _level = updatedLevel;
    });

    Fluttertoast.showToast(
      msg: "Today's entry removed. XP and streak updated.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  } catch (e) {
    print('Error resetting today: $e');
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
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 55,
            child: ElevatedButton(
              onPressed: _saveNonSmokingDay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
                    duration: const Duration(milliseconds: 200),
                    opacity: _isProcessing ? 0 : 1,
                    child: Text(
                      'Add Non-Smoked Day',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isProcessing ? 1 : 0,
                    child: const SizedBox(
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
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
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
                height: 40,
                width: 1,
                color: Colors.grey.shade300,
              ),
              _buildStatItem(
                icon: Icons.star,
                label: 'Level',
                value: '$_level',
                color: Colors.amber,
              ),
            ],
          ),
          const Divider(height: 30),
          _buildStatItem(
            icon: Icons.emoji_events,
            label: 'Total XP',
            value: '$_totalXP XP',
            color: Colors.green,
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
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isLarge ? 16 : 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 24,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
  final now = DateTime.now();
  if (selectedDay.year != now.year ||
      selectedDay.month != now.month ||
      selectedDay.day != now.day) {
    Fluttertoast.showToast(
      msg: "You can only select today's date.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    return;
  }

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
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reset Progress'),
              content: const Text(
                  'Are you sure you want to reset all your progress? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _resetData();
                    Navigator.pop(context);
                  },
                  child:
                      const Text('Reset', style: TextStyle(color: Colors.red)),
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smoke_free,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Non-Smoking Tracker',
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildStatsCard(),
              ),
              Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      Center(
        child: Text(
          "You can fool FreshStart, but you can't fool yourself",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: const Color.fromARGB(137, 21, 0, 255),
          ),
        ),
      ),
      _buildCalendarCard(),
      const SizedBox(height: 20),
                
      const SizedBox(height: 12),
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
