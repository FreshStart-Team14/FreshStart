import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add this to pubspec.yaml if not already present

class SavedMoneyScreen extends StatefulWidget {
  @override
  _SavedMoneyScreenState createState() => _SavedMoneyScreenState();
}

class _SavedMoneyScreenState extends State<SavedMoneyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final currencyFormat = NumberFormat.currency(
    symbol: '₺',
    locale: 'tr_TR',
    decimalDigits: 2,
  );

  double _cigarettesPerDay = 0;
  double _packPrice = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _cigarettesPerDay =
            double.parse(userData['cigarettes_per_day']?.toString() ?? '0');
        _packPrice = double.parse(userData['cost_per_pack']?.toString() ?? '0');
        _isLoading = false;
      });
    }
  }

  Widget _buildSavingsCard(String period, String timeFrame, double amount) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    timeFrame,
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              currencyFormat.format(amount),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Calculate savings (assuming 20 cigarettes per pack)
    double dailySavings = (_cigarettesPerDay / 20) * _packPrice;
    double weeklySavings = dailySavings * 7;
    double monthlySavings = dailySavings * 30;
    double yearlySavings = dailySavings * 365;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Savings Forecast',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Potential Savings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Based on ${_cigarettesPerDay.toStringAsFixed(0)} cigarettes/day',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  _buildSavingsCard('Daily Savings', '24 HOURS', dailySavings),
                  _buildSavingsCard('Weekly Savings', '7 DAYS', weeklySavings),
                  _buildSavingsCard(
                      'Monthly Savings', '30 DAYS', monthlySavings),
                  _buildSavingsCard(
                      'Yearly Savings', '365 DAYS', yearlySavings),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: Colors.orange[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[800]),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'These calculations are based on your current pack price of ${currencyFormat.format(_packPrice)}',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
