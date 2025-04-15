import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NonSmokedCigarettesScreen extends StatefulWidget {
  @override
  _NonSmokedCigarettesScreenState createState() =>
      _NonSmokedCigarettesScreenState();
}

class _NonSmokedCigarettesScreenState
    extends State<NonSmokedCigarettesScreen> {
  int nonSmokingDays = 0;

  final List<Map<String, dynamic>> toxinRecoveryData = [
    {
      'name': 'Carbon Monoxide',
      'recoveryDays': 1,
    },
    {
      'name': 'Nicotine',
      'recoveryDays': 3,
    },
    {
      'name': 'Tar',
      'recoveryDays': 30,
    },
    {
      'name': 'Immune Strength',
      'recoveryDays': 10,
    },
    {
      'name': 'Lung Clean-up',
      'recoveryDays': 90,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadNonSmokingData();
  }

  Future<void> _loadNonSmokingData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final List<dynamic> days = snapshot.get('nonSmokingDays') ?? [];
        setState(() {
          nonSmokingDays = days.length;
        });
      }
    }
  }

  Widget _buildToxinProgress(Map<String, dynamic> toxin) {
    final int recoveryDays = toxin['recoveryDays'];
    final double progress =
        (nonSmokingDays / recoveryDays).clamp(0.0, 1.0);
    final bool isRecovered = progress >= 1.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                toxin['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                isRecovered ? '✅ Recovered' : '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: isRecovered ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            color: isRecovered ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Non-Smoked Cigarettes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Non-Smoking Days: $nonSmokingDays',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: toxinRecoveryData.length,
                itemBuilder: (context, index) {
                  return _buildToxinProgress(toxinRecoveryData[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
