import 'package:flutter/material.dart';
import 'precise_emotions_screen.dart';

class ConfidenceScreen extends StatefulWidget {
  final String mainEmotion;

  ConfidenceScreen({required this.mainEmotion});

  @override
  _ConfidenceScreenState createState() => _ConfidenceScreenState();
}

class _ConfidenceScreenState extends State<ConfidenceScreen> {
  double _confidence = 50;

  String get confidenceLevel {
    if (_confidence < 30) return 'I might need more support';
    if (_confidence < 60) return 'I can handle the cravings';
    if (_confidence < 85) return 'I feel strong today';
    return 'I\'m fully committed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence Check'),
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
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'How confident are you about staying smoke-free today?',
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Even while feeling ${widget.mainEmotion.toLowerCase()}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
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
                    Text(
                      confidenceLevel,
                      style: TextStyle(
                        fontSize: 24, 
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Slider(
                      value: _confidence,
                      min: 0,
                      max: 100,
                      activeColor: Colors.blue.shade800,
                      inactiveColor: Colors.blue.shade100,
                      onChanged: (value) {
                        setState(() {
                          _confidence = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreciseEmotionsScreen(
                        mainEmotion: widget.mainEmotion,
                        confidence: confidenceLevel,
                      ),
                    ),
                  );
                },
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
            ],
          ),
        ),
      ),
    );
  }
} 