import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class SavedMoneyScreen extends StatefulWidget {
  @override
  _SavedMoneyScreenState createState() => _SavedMoneyScreenState();
}

class _SavedMoneyScreenState extends State<SavedMoneyScreen>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  String dailyTip = '';
  bool showMilestone = false;
  String milestoneMessage = '';

  final List<String> moneyTips = [
    "Consider investing your savings for long-term growth!",
    "Your savings could fund a nice vacation!",
    "Think about what you could do with this extra money!",
    "Your future self will thank you for these savings!",
    "Small savings add up to big rewards!",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadUserData();
    _setDailyTip();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setDailyTip() {
    final random = Random();
    setState(() {
      dailyTip = moneyTips[random.nextInt(moneyTips.length)];
    });
  }

  void _checkMilestones(double amount) {
    final List<Map<String, dynamic>> milestones = [
      {'amount': 1000.0, 'message': 'You\'ve saved over ₺1,000!'},
      {'amount': 5000.0, 'message': 'Amazing! ₺5,000 saved!'},
      {'amount': 10000.0, 'message': 'Incredible! ₺10,000 milestone!'},
    ];

    for (var milestone in milestones) {
      final milestoneAmount = milestone['amount'] as double;
      final message = milestone['message'] as String;
      if (amount >= milestoneAmount && amount < milestoneAmount + 100) {
        setState(() {
          showMilestone = true;
          milestoneMessage = message;
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => showMilestone = false);
        });
        break;
      }
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
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
      _animationController.forward();
    }
  }

  Widget _buildSavingsCard(String period, String timeFrame, double amount) {
    final bool isMilestone = amount >= 1000 && amount < 1100 ||
        amount >= 5000 && amount < 5100 ||
        amount >= 10000 && amount < 10100;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isMilestone
                            ? Colors.blue.shade100
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.savings,
                        color: isMilestone ? Colors.blue.shade800 : Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    timeFrame,
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) => Text(
                currencyFormat.format(amount * _progressAnimation.value),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            if (isMilestone) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Milestone Achieved!',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      );
    }

    // Calculate savings (assuming 20 cigarettes per pack)
    double dailySavings = (_cigarettesPerDay / 20) * _packPrice;
    double weeklySavings = dailySavings * 7;
    double monthlySavings = dailySavings * 30;
    double yearlySavings = dailySavings * 365;

    _checkMilestones(yearlySavings);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Savings Forecast',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue),
            onPressed: () {
              _loadUserData();
              _setDailyTip();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smoke_free,
                          color: Colors.blue,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_cigarettesPerDay.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cigarettes Per Day',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dailyTip,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade800,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSavingsCard(
                        'Daily Savings', '24 HOURS', dailySavings),
                    _buildSavingsCard(
                        'Weekly Savings', '7 DAYS', weeklySavings),
                    _buildSavingsCard(
                        'Monthly Savings', '30 DAYS', monthlySavings),
                    _buildSavingsCard(
                        'Yearly Savings', '365 DAYS', yearlySavings),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Based on ${currencyFormat.format(_packPrice)} per pack (20 cigarettes)',
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showMilestone)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.celebration,
                          color: Colors.blue,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          milestoneMessage,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Keep up the great work!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
