import 'package:flutter/material.dart';

class EmotionTrackerScreen extends StatefulWidget {
  @override
  _EmotionTrackerScreenState createState() => _EmotionTrackerScreenState();
}

class _EmotionTrackerScreenState extends State<EmotionTrackerScreen> {
  String mainEmotion = 'Calm';
  List<String> preciseEmotions = ['Compassion', 'Amusement', 'Peace'];
  String confidence = 'Somewhat confident';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Text('Back'),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            SizedBox(height: 40),
            _buildSummaryItem('My main emotion:', mainEmotion),
            SizedBox(height: 20),
            _buildSummaryItem(
              'More precisely:',
              preciseEmotions.join(', '),
            ),
            SizedBox(height: 20),
            _buildSummaryItem('My confidence:', confidence),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Continue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.amber,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
} 