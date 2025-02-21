
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

class NonSmokingTrackerScreen extends StatefulWidget { //Since we deal with dynamic data here, stateful is used here
  @override
  _NonSmokingTrackerScreenState createState() => _NonSmokingTrackerScreenState();
}

class _NonSmokingTrackerScreenState extends State<NonSmokingTrackerScreen> {

  Map<DateTime, List<String>> _nonSmokingDays = {};
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month; //From flutter package
  int _currentStreak = 0;
  int _totalXP = 0;
  int _level = 1; //Variables

  @override
  void initState() { //This method is called when widget is first created
    super.initState();
    _loadNonSmokingDays();
    _loadStreakData();
  }

  void _loadNonSmokingDays() async { 
    String userId = FirebaseAuth.instance.currentUser!.uid; //Get user's id to fetch its data
    
    // Load non-smoking days from Firestore
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get(); //DocumentSnapshot is a firestore package. Stores single document values in it
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
    
    // Load streak data from Firestore
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get(); //DocumentSnapshot is a firestore package. Stores single document values in it
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

  // SharedPreferences is flutter plugin to store data in key-value format on user device
  void _checkForStreakReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); //Gets user's saved preference instance
    DateTime lastAddedDay = DateTime.parse(prefs.getString('lastAddedDay') ?? DateTime.now().toIso8601String()); //toIso8601String() converts date into string format, dart built-in function

    if (DateTime.now().difference(lastAddedDay).inDays > 1) {
      _currentStreak = 0; 
      await prefs.setInt('currentStreak', _currentStreak); //Updates saved preference of the user
    }
  }

  void _saveNonSmokingDay() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDays = _nonSmokingDays.keys.map((e) => e.toIso8601String()).toList();

    final todayString = DateTime.now().toIso8601String().split('T')[0];

    if (!savedDays.contains(todayString)) { //To check if user already gave entry to streak already or not
      savedDays.add(todayString);
      _nonSmokingDays[DateTime.now()] = ['Non-Smoked'];
      
      
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({ //To save non-smoked day to firestore
          'nonSmokingDays': savedDays,
        });
        _updateStreakAndXP(); //Update streak and XP after saving the day
      } catch (e) {
        print('Error saving non-smoked day to Firestore: $e');
      }      
      await prefs.setString('lastAddedDay', DateTime.now().toIso8601String()); //Update last added day to prevent reset on next check
    } else {
      print('Non-smoked day already recorded for today.');
    }
    
    setState(() {
      _nonSmokingDays[DateTime.now()] = ['Non-Smoked'];
    });
  }

  void _updateStreakAndXP() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    _currentStreak++;
    
    int earnedXP = (_currentStreak % 15 == 0) ? (_currentStreak ~/ 15) * 500 : 0; //update XP based on current streak
    _totalXP += earnedXP;
    _level = _calculateLevel(_totalXP);

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({ //firestore update
        'currentStreak': _currentStreak,
        'totalXP': _totalXP,
        'level': _level,
        'lastAddedDay': DateTime.now().toIso8601String(),
      });
      print('Document updated successfully.');
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
      await FirebaseFirestore.instance.collection('users').doc(userId).update({ //to reset progress in firestore
        'currentStreak': 0,
        'totalXP': 0,
        'level': 1,
        'lastAddedDay': DateTime.now().toIso8601String(),
        'nonSmokingDays': [],
      });

      setState(() { //To reset local state
        _currentStreak = 0;
        _totalXP = 0;
        _level = 1;
        _nonSmokingDays.clear(); // Clear the local non-smoking days
      });
    } catch (e) {
      print('Error resetting data in Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Non-Smoking Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor:Colors.blueAccent, // header
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TableCalendar( //Calendar Widget from flutter package
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
                ),
              ),
            ),
            SizedBox(height: 20),
            // Add Non-Smoked Day Button
            ElevatedButton( // Button design to save non smoked day
              onPressed: _saveNonSmokingDay, //when pressed this method is launched
              child: Text('Add Non-Smoked Day'),
              style: ElevatedButton.styleFrom(
                backgroundColor:Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton( // Reset Streak Button
              onPressed: _resetData, //When this button is clicked this method will be launched
              child: Text('Reset Streak, XP, and Level'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red button for resetting
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Streak, XP, Level Information
            Text(
              'Current Streak: $_currentStreak days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Total XP: $_totalXP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Level: $_level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

