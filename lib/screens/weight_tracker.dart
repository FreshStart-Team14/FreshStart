import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class WeightTrackerScreen extends StatefulWidget { //Dynamic class so that we used state
  @override
  _WeightTrackerScreenState createState() => _WeightTrackerScreenState(); //Holds all the logic
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final TextEditingController _weightController = TextEditingController(); //User controller where user will enter the weight
  List<WeightEntry> _weightEntries = []; //To store the weight
  String? _firstWeightEntryId;

  @override
  void initState() { //Called when user first enters the page
    super.initState();
    _fetchWeightHistory();
  }

  Future<void> _fetchWeightHistory() async { //To get weight history of the user
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance //DocumentSnapshot is a firestore package. Stores single document values in it
        .collection('users')
        .doc(userId)
        .collection('weights')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      _weightEntries = snapshot.docs.map((doc) {
        
        if (_firstWeightEntryId == null) { //to store the ID of the first entry
          _firstWeightEntryId = doc.id; //to store the ID of the first document
        }
        return WeightEntry(
          id: doc.id,
          weight: doc['weight'],
          date: (doc['date'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  Future<void> _addWeight() async {
    if (_weightController.text.isEmpty) {
      _showErrorDialog('Please enter a weight.');
      return;
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;
    int weight = int.parse(_weightController.text);

    await FirebaseFirestore.instance //Adds newly entered weight to the firestore weight sub collection
        .collection('users')
        .doc(userId)
        .collection('weights')
        .add({
      'weight': weight,
      'date': Timestamp.now(),
    });

    
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'weight': weight, // To update the main document field
    });

    _weightController.clear();
    _fetchWeightHistory(); 
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weight Tracker', style: TextStyle(fontWeight: FontWeight.bold)), //Title of the page
        centerTitle: true,
        backgroundColor: Colors.blueAccent, //Stylish header
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: 'Enter Weight (kg)'), //Input part for the weight entry
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton( // Button design to save weight
              onPressed: _addWeight, //when pressed this method is launched
              child: Text('Add Non-Smoked Day'),
              style: ElevatedButton.styleFrom(
                backgroundColor:Colors.blueAccent,
                textStyle: TextStyle(fontSize: 16),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 20),
            Text('Weight History:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder( //Built in flutter widget
                itemCount: _weightEntries.length,
                itemBuilder: (context, index) {
                  final entry = _weightEntries[index];
                  String formattedDate = DateFormat('dd MMMM yyyy').format(entry.date);
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Weight: ${entry.weight} kg'),
                      subtitle: Text('Date: $formattedDate'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightEntry {
  final String id;
  final int weight;
  final DateTime date;

  WeightEntry({required this.id, required this.weight, required this.date});
}

