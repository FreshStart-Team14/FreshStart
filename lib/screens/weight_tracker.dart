import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class WeightTrackerScreen extends StatefulWidget {
  //Dynamic class so that we used state
  @override
  _WeightTrackerScreenState createState() =>
      _WeightTrackerScreenState(); //Holds all the logic
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _weightController =
      TextEditingController(); //User controller where user will enter the weight
  List<WeightEntry> _weightEntries = []; //To store the weight
  String? _firstWeightEntryId;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  String dailyTip = '';
  bool showMilestone = false;
  String milestoneMessage = '';
  bool _isProcessing = false;

  final List<String> healthTips = [
    "Small, consistent changes lead to big results!",
    "Stay hydrated throughout the day!",
    "Remember to celebrate your progress!",
    "Your body is unique - focus on your journey!",
    "Consistency is key to long-term success!",
  ];

  @override
  void initState() {
    //Called when user first enters the page
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    );

    _fetchWeightHistory();
    _setDailyTip();
    _animationController.forward();
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressAnimationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeightHistory() async {
    //To get weight history of the user
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore
        .instance //DocumentSnapshot is a firestore package. Stores single document values in it
        .collection('users')
        .doc(userId)
        .collection('weights')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      _weightEntries = snapshot.docs.map((doc) {
        if (_firstWeightEntryId == null) {
          //to store the ID of the first entry
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

  void _setDailyTip() {
    final random = Random();
    setState(() {
      dailyTip = healthTips[random.nextInt(healthTips.length)];
    });
  }

  void _checkMilestones(int weight) {
    if (_weightEntries.isNotEmpty) {
      final firstWeight = _weightEntries.last.weight;
      final difference = firstWeight - weight;

      if (difference >= 5) {
        setState(() {
          showMilestone = true;
          milestoneMessage = '5kg Lost! Amazing Progress!';
        });
      } else if (difference >= 10) {
        setState(() {
          showMilestone = true;
          milestoneMessage = '10kg Milestone Reached!';
        });
      }

      if (showMilestone) {
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => showMilestone = false);
        });
      }
    }
  }

  Future<void> _addWeight() async {
    if (_weightController.text.isEmpty) {
      _showErrorDialog('Please enter a weight.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      int weight = int.parse(_weightController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('weights')
          .add({
        'weight': weight,
        'date': Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'weight': weight,
      });

      _weightController.clear();
      await _fetchWeightHistory();

      // Check weight change after adding new weight
      if (_weightEntries.length > 1) {
        double change = _weightEntries[0].weight.toDouble() -
            _weightEntries[1].weight.toDouble();

        if (change >= 2) {
          // Significant weight gain (2kg or more)
          _showWeightAlert(
              'Weight Gain Alert',
              'We noticed a significant increase in your weight. Would you like to check our personalized diet plans to help you get back on track?',
              true);
        } else if (change <= -1) {
          // Weight loss (1kg or more)
          _showWeightAlert(
              'Congratulations! 🎉',
              'Great job on your weight loss progress! Keep up the good work!',
              false);
        }
      }

      _checkMilestones(weight);
    } catch (e) {
      _showErrorDialog('Error adding weight: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showWeightAlert(String title, String message, bool isDietSuggestion) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(
                    isDietSuggestion
                        ? Icons.warning_amber_rounded
                        : Icons.celebration,
                    color: isDietSuggestion ? Colors.orange : Colors.green,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isDietSuggestion
                            ? Colors.orange[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              actionsPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
    );
  }

  List<FlSpot> _createSpots() {
    final recentEntries = _weightEntries.take(8).toList().reversed.toList();
    return List.generate(recentEntries.length, (index) {
      return FlSpot(index.toDouble(), recentEntries[index].weight.toDouble());
    });
  }

  Widget _buildChart() {
    if (_weightEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey[300]),
            SizedBox(height: 8),
            Text(
              'No weight data available',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= _weightEntries.take(8).length) {
                  return const Text('');
                }
                final date = _weightEntries
                    .take(8)
                    .toList()
                    .reversed
                    .toList()[value.toInt()]
                    .date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('dd/MM').format(date),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                );
              },
              interval: 10,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _createSpots(),
            isCurved: true,
            color: Colors.blue[700],
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue[700]!,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue[700]!.withOpacity(0.1),
            ),
          ),
        ],
        minY: (_weightEntries
                    .map((e) => e.weight)
                    .reduce((a, b) => a < b ? a : b) -
                5)
            .toDouble(),
        maxY: (_weightEntries
                    .map((e) => e.weight)
                    .reduce((a, b) => a > b ? a : b) +
                5)
            .toDouble(),
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
              Icons.monitor_weight,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Weight Tracker',
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
              _fetchWeightHistory();
              _setDailyTip();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildWeightInputCard(),
                const SizedBox(height: 20),
                _buildChartCard(),
                const SizedBox(height: 20),
                _buildHistoryCard(),
                const SizedBox(height: 20),
              ],
            ),
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

  Widget _buildWeightInputCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          children: [
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Enter Weight (kg)',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon:
                    Icon(Icons.monitor_weight_outlined, color: Colors.blue),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _addWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Add Weight',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 280,
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
      padding: const EdgeInsets.all(20),
      child: _buildChart(),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Weight History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _weightEntries.length,
              itemBuilder: (context, index) {
                final entry = _weightEntries[index];
                String formattedDate =
                    DateFormat('dd MMMM yyyy').format(entry.date);

                String changeText = '';
                if (index < _weightEntries.length - 1) {
                  double change = _weightEntries[index].weight.toDouble() -
                      _weightEntries[index + 1].weight.toDouble();
                  changeText = '${change > 0 ? '+' : ''}$change kg';
                }

                return _buildAnimatedListItem(
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.weight} kg',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (changeText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: changeText.startsWith('+')
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              changeText,
                              style: TextStyle(
                                color: changeText.startsWith('+')
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedListItem(Widget child, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.5, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (index * 0.1).clamp(0, 1),
              ((index * 0.1) + 0.6).clamp(0, 1),
              curve: Curves.easeOutQuart,
            ),
          )),
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class WeightEntry {
  final String id;
  final int weight;
  final DateTime date;

  WeightEntry({required this.id, required this.weight, required this.date});
}
