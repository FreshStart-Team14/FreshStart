import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class NonSmokedCigarettesScreen extends StatefulWidget {
  @override
  _NonSmokedCigarettesScreenState createState() =>
      _NonSmokedCigarettesScreenState();
}

class _NonSmokedCigarettesScreenState extends State<NonSmokedCigarettesScreen>
    with SingleTickerProviderStateMixin {
  int nonSmokingDays = 0;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  String dailyQuote = '';
  bool isLoading = true;
  bool showCelebration = false;

  final List<String> motivationalQuotes = [
    "Every day smoke-free is a victory!",
    "Your health is your greatest wealth.",
    "Small steps lead to big changes.",
    "You're stronger than your cravings.",
    "Each day is a new opportunity to be better.",
  ];

  final List<Map<String, dynamic>> toxinRecoveryData = [
    {
      'name': 'Carbon Monoxide',
      'recoveryDays': 1,
      'icon': Icons.air,
      'description': 'Your blood oxygen levels return to normal.',
      'milestone': 'First Day',
    },
    {
      'name': 'Nicotine',
      'recoveryDays': 3,
      'icon': Icons.smoke_free,
      'description': 'Nicotine is completely eliminated from your body.',
      'milestone': 'Three Days',
    },
    {
      'name': 'Tar',
      'recoveryDays': 30,
      'icon': Icons.cleaning_services,
      'description': 'Your lungs begin to clear out tar and other toxins.',
      'milestone': 'One Month',
    },
    {
      'name': 'Immune Strength',
      'recoveryDays': 10,
      'icon': Icons.health_and_safety,
      'description': 'Your immune system starts to strengthen.',
      'milestone': 'Ten Days',
    },
    {
      'name': 'Lung Clean-up',
      'recoveryDays': 90,
      'icon': Icons.favorite,
      'description': 'Your lung function improves significantly.',
      'milestone': 'Three Months',
    },
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
    _loadNonSmokingData();
    _setDailyQuote();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setDailyQuote() {
    final random = Random();
    setState(() {
      dailyQuote =
          motivationalQuotes[random.nextInt(motivationalQuotes.length)];
    });
  }

  void _checkMilestones() {
    final milestones = toxinRecoveryData
        .where((toxin) => nonSmokingDays == toxin['recoveryDays'])
        .toList();
    if (milestones.isNotEmpty) {
      setState(() => showCelebration = true);
      Future.delayed(const Duration(seconds: 3), () {
        setState(() => showCelebration = false);
      });
    }
  }

  Future<void> _loadNonSmokingData() async {
    setState(() => isLoading = true);
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
          isLoading = false;
        });
        _animationController.forward();
        _checkMilestones();
      }
    }
  }

  void _showInfoDialog() {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'About Recovery Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This timeline shows your body\'s recovery process after quitting smoking. Each milestone represents a significant health improvement:',
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              SizedBox(height: 16),
              ...toxinRecoveryData.map(
                (toxin) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(toxin['icon'], color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toxin['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              toxin['description'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}


  Widget _buildToxinProgress(Map<String, dynamic> toxin) {
    final int recoveryDays = toxin['recoveryDays'];
    final double progress = (nonSmokingDays / recoveryDays).clamp(0.0, 1.0);
    final bool isRecovered = progress >= 1.0;
    final bool isMilestone = nonSmokingDays == recoveryDays;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isMilestone ? Colors.blue.shade100 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  toxin['icon'],
                  color: isMilestone ? Colors.blue.shade800 : Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toxin['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recoveryDays} days to recover',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isRecovered
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isRecovered ? 'Recovered' : '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: isRecovered ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: isRecovered ? Colors.green : Colors.blue,
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
                    'Milestone Achieved: ${toxin['milestone']}',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_rounded,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Recovery Progress',
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
              _loadNonSmokingData();
              _setDailyQuote();
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.blue),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Stack(
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
                                Icons.celebration,
                                color: Colors.blue,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) => Text(
                                  '${(nonSmokingDays * _progressAnimation.value).toInt()}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Days Smoke-Free',
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
                                    dailyQuote,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Recovery Timeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: toxinRecoveryData.length,
                        itemBuilder: (context, index) {
                          return _buildToxinProgress(toxinRecoveryData[index]);
                        },
                      ),
                    ),
                  ],
                ),
                if (showCelebration)
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
                                'Milestone Achieved!',
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
