
/*
  void _saveNonSmokingDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDays = prefs.getStringList('nonSmokingDays') ?? [];

    final todayString = DateTime.now().toIso8601String().split('T')[0];
    if (!savedDays.contains(todayString)) {
      savedDays.add(todayString);
      await prefs.setStringList('nonSmokingDays', savedDays);
      _updateStreakAndXP();
    }
    
    setState(() {
      _nonSmokingDays[DateTime.now()] = ['Non-Smoked'];
    });
  }
*/
/*
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NonSmokingTrackerScreen extends StatefulWidget {
  @override
  _NonSmokingTrackerScreenState createState() => _NonSmokingTrackerScreenState();
}

class _NonSmokingTrackerScreenState extends State<NonSmokingTrackerScreen> {
  Map<DateTime, List<String>> _nonSmokingDays = {};
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  int _currentStreak = 0;
  int _totalXP = 0;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _loadNonSmokingDays();
    _loadStreakData();
  }

  void _loadNonSmokingDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedDays = prefs.getStringList('nonSmokingDays') ?? [];

    setState(() {
      _nonSmokingDays = {
        for (var day in savedDays) DateTime.parse(day): ['Non-Smoked']
      };
    });
  }

  void _loadStreakData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _totalXP = prefs.getInt('totalXP') ?? 0;
    _level = prefs.getInt('level') ?? 1;
    _checkForStreakReset();
  }

  void _checkForStreakReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastAddedDay = DateTime.parse(prefs.getString('lastAddedDay') ?? DateTime.now().toIso8601String());

    if (DateTime.now().difference(lastAddedDay).inDays > 1) {
      _currentStreak = 0; // Reset streak if no days are added in between
      await prefs.setInt('currentStreak', _currentStreak);
    }
  }

  void _saveNonSmokingDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDays = prefs.getStringList('nonSmokingDays') ?? [];

    final todayString = DateTime.now().toIso8601String().split('T')[0];

    // For testing, allow adding the same day multiple times
    if (!savedDays.contains(todayString)) {
      savedDays.add(todayString);
      await prefs.setStringList('nonSmokingDays', savedDays);
      _updateStreakAndXP();
    } else {
      // Add logic here for testing, e.g., adding a new day
      DateTime newDay = DateTime.now().add(Duration(days: 1));
      String newDayString = newDay.toIso8601String().split('T')[0];
      savedDays.add(newDayString);
      await prefs.setStringList('nonSmokingDays', savedDays);
      _updateStreakAndXP();
    }

    setState(() {
      _nonSmokingDays[DateTime.now()] = ['Non-Smoked'];
    });
  }

  void _updateStreakAndXP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentStreak++;
    await prefs.setInt('currentStreak', _currentStreak);

    // Update XP based on current streak
    int earnedXP = (_currentStreak % 15 == 0) ? (_currentStreak ~/ 15) * 500 : 0;

    _totalXP += earnedXP;
    await prefs.setInt('totalXP', _totalXP);
    _level = _calculateLevel(_totalXP);
    await prefs.setInt('level', _level);
    await prefs.setString('lastAddedDay', DateTime.now().toIso8601String());
  }

  int _calculateLevel(int xp) {
    int level = 1;
    int requiredXP = 500;

    while (level <= 150 && xp >= requiredXP) {
      xp -= requiredXP;
      level++;
      requiredXP += 500; // Increase required XP for the next level
    }

    return level; // Returns the current level, maxing out at 150
  }

  void _resetData() async { // TEST-----------------------------------------
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentStreak', 0);
    await prefs.setInt('totalXP', 0);
    await prefs.setInt('level', 1);
    await prefs.setString('lastAddedDay', DateTime.now().toIso8601String());

    // Optionally, clear the non-smoking days as well
    await prefs.setStringList('nonSmokingDays', []);

    // Reset the local state
    setState(() {
      _currentStreak = 0;
      _totalXP = 0;
      _level = 1;
      _nonSmokingDays.clear(); // Clear the local non-smoking days
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Non-Smoking Tracker'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _calendarFormat = CalendarFormat.month;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              return _nonSmokingDays[day] ?? [];
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
              // This highlights the days when the user logs non-smoking days
            ),
          ),
          ElevatedButton(
            onPressed: _saveNonSmokingDay,
            child: Text('Add Non-Smoked Day'),
          ),
          ElevatedButton( // TEST------------------------------------
            onPressed: _resetData,
            child: Text('Reset Streak, XP, and Level'),
          ),
          SizedBox(height: 20),
          Text('Current Streak: $_currentStreak days'),
          Text('Total XP: $_totalXP'),
          Text('Level: $_level'),
        ],
      ),
    );
  }
}

*/




import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NonSmokingTrackerScreen extends StatefulWidget {
  @override
  _NonSmokingTrackerScreenState createState() => _NonSmokingTrackerScreenState();
}

class _NonSmokingTrackerScreenState extends State<NonSmokingTrackerScreen> {
  Map<DateTime, List<String>> _nonSmokingDays = {};
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _currentStreak = 0;
  int _totalXP = 0;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _loadNonSmokingDays();
    _loadStreakData();
  }

  void _loadNonSmokingDays() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        List<String> savedDays = List<String>.from(snapshot.get('nonSmokingDays') ?? []);
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
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
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
    DateTime lastAddedDay = DateTime.parse(prefs.getString('lastAddedDay') ?? DateTime.now().toIso8601String());

    if (DateTime.now().difference(lastAddedDay).inDays > 1) {
      _currentStreak = 0;
      await prefs.setInt('currentStreak', _currentStreak);
    }
  }

  void _saveNonSmokingDay() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDays = _nonSmokingDays.keys.map((e) => e.toIso8601String().split('T')[0]).toList();

    final todayString = DateTime.now().toIso8601String().split('T')[0];

    if (!savedDays.contains(todayString)) {
      savedDays.add(todayString);
      _nonSmokingDays[DateTime.now()] = ['Non-Smoked'];

      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
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

    setState(() {
      _nonSmokingDays[DateTime.now()] = ['Non-Smoked'];
    });
  }

  void _updateStreakAndXP() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    _currentStreak++;

    int earnedXP = (_currentStreak % 15 == 0) ? (_currentStreak ~/ 15) * 500 : 0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 157, 157, 157), // Light grey background
      appBar: AppBar(
        title: Text(
          'Non-Smoking Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Blue header
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Calendar remains white
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
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
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNonSmokingDay,
              child: Text(
                'Add Non-Smoked Day',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _resetData,
              child: Text('Reset Streak, XP, and Level'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Current Streak: $_currentStreak days'),
                _infoRow('Total XP: $_totalXP'),
                _infoRow('Level: $_level'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String text) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}



