import 'package:flutter/material.dart';
import 'emotion_summary_screen.dart';

class PreciseEmotionsScreen extends StatefulWidget {
  final String mainEmotion;
  final String confidence;

  PreciseEmotionsScreen({
    required this.mainEmotion,
    required this.confidence,
  });

  @override
  _PreciseEmotionsScreenState createState() => _PreciseEmotionsScreenState();
}

class _PreciseEmotionsScreenState extends State<PreciseEmotionsScreen> {
  final List<String> selectedEmotions = [];
  
  Map<String, List<String>> emotionDetails = {
    'Determined': [
      'Focused', 
      'Motivated', 
      'Resolute', 
      'Committed', 
      'Driven', 
      'Purposeful'
    ],
    'Stressed': [
      'Overwhelmed', 
      'Tense', 
      'Pressured', 
      'Restless', 
      'Agitated', 
      'Worried'
    ],
    'Proud': [
      'Accomplished', 
      'Confident', 
      'Satisfied', 
      'Strong', 
      'Empowered', 
      'Successful'
    ],
    'Challenged': [
      'Struggling', 
      'Testing', 
      'Determined', 
      'Fighting', 
      'Persevering', 
      'Enduring'
    ],
    'Calm': [
      'Peaceful', 
      'Relaxed', 
      'Serene', 
      'Composed', 
      'Centered', 
      'Balanced'
    ],
    'Anxious': [
      'Nervous', 
      'Uneasy', 
      'Worried', 
      'Fearful', 
      'Apprehensive', 
      'Concerned'
    ],
  };

  @override
  Widget build(BuildContext context) {
    final List<String> availableEmotions = emotionDetails[widget.mainEmotion] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Precise Emotions'),
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select 3 emotions that best describe your ${widget.mainEmotion.toLowerCase()} state:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: availableEmotions.length,
                itemBuilder: (context, index) {
                  final emotion = availableEmotions[index];
                  final isSelected = selectedEmotions.contains(emotion);

                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        emotion,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Colors.blue.shade800)
                          : Icon(Icons.circle_outlined),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedEmotions.remove(emotion);
                          } else if (selectedEmotions.length < 3) {
                            selectedEmotions.add(emotion);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: selectedEmotions.length == 3
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmotionSummaryScreen(
                              mainEmotion: widget.mainEmotion,
                              confidence: widget.confidence,
                              preciseEmotions: selectedEmotions,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  'Continue',
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
            ),
          ],
        ),
      ),
    );
  }
} 