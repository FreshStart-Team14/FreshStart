import 'package:flutter/material.dart';
import 'confidence_screen.dart';

class EmotionSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> emotions = [
    {
      'emotion': 'Determined',
      'color': Colors.blue.shade800,
      'icon': Icons.flag,
      'description': 'Ready to achieve my goals'
    },
    {
      'emotion': 'Stressed',
      'color': Colors.red,
      'icon': Icons.warning_amber,
      'description': 'Feeling pressure'
    },
    {
      'emotion': 'Proud',
      'color': Colors.green,
      'icon': Icons.emoji_events,
      'description': 'Making progress'
    },
    {
      'emotion': 'Challenged',
      'color': Colors.orange,
      'icon': Icons.fitness_center,
      'description': 'Facing cravings'
    },
    {
      'emotion': 'Calm',
      'color': Colors.teal,
      'icon': Icons.spa,
      'description': 'At peace'
    },
    {
      'emotion': 'Anxious',
      'color': Colors.purple,
      'icon': Icons.psychology,
      'description': 'Feeling uncertain'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How are you feeling today?'),
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
        child: GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: emotions.length,
          itemBuilder: (context, index) {
            return _buildEmotionCard(context, emotions[index]);
          },
        ),
      ),
    );
  }

  Widget _buildEmotionCard(BuildContext context, Map<String, dynamic> emotion) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfidenceScreen(mainEmotion: emotion['emotion']),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emotion['icon'],
                size: 48,
                color: emotion['color'],
              ),
              SizedBox(height: 12),
              Text(
                emotion['emotion'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                emotion['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 