import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmotionSummaryScreen extends StatelessWidget {
  final String mainEmotion;
  final String confidence;
  final List<String> preciseEmotions;

  EmotionSummaryScreen({
    required this.mainEmotion,
    required this.confidence,
    required this.preciseEmotions,
  });

  @override
  Widget build(BuildContext context) {
    _saveEmotionalState(mainEmotion, confidence, preciseEmotions);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Summary'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade50],
            stops: [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Emotional State',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildSummaryItem(
                        'Main Feeling:',
                        mainEmotion,
                        Icons.mood,
                      ),
                      SizedBox(height: 20),
                      _buildSummaryItem(
                        'More Specifically:',
                        preciseEmotions.join(', '),
                        Icons.psychology,
                      ),
                      SizedBox(height: 20),
                      _buildSummaryItem(
                        'Confidence Level:',
                        confidence,
                        Icons.trending_up,
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Keep going! Every emotion is part of your journey.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEmotionalState(String mainEmotion, String confidence, List<String> preciseEmotions) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> emotionalStates = prefs.getStringList('emotionalStates') ?? [];
    
    // Create a new emotional state entry
    String newState = 'Main: $mainEmotion, Confidence: $confidence, Precise: ${preciseEmotions.join(', ')}';
    
    // Add the new state and limit to the last 5 entries
    emotionalStates.add(newState);
    if (emotionalStates.length > 5) {
      emotionalStates.removeAt(0); // Remove the oldest entry
    }
    
    await prefs.setStringList('emotionalStates', emotionalStates);
    
    // Save the last entry date
    await prefs.setString('lastEntryDate', DateTime.now().toIso8601String());
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue.shade800,
            size: 24,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 