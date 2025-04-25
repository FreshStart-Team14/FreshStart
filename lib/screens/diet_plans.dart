import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freshstart/src/services/openai_service.dart';

class DietPlansScreen extends StatefulWidget {
  @override
  _DietPlansScreenState createState() => _DietPlansScreenState();
}

class _DietPlansScreenState extends State<DietPlansScreen> {
  double? bmi;
  String bmiCategory = '';
  Map<String, List<String>> dietPlan = {};

  @override
  void initState() {
    super.initState();
    _calculateBMI();
  }

  Future<void> _calculateBMI() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userDoc.exists) {
    final weight = userDoc.data()?['weight'] as num?;
    final height = userDoc.data()?['height'] as num?;
    final storedDietPlan = userDoc.data()?['dietPlan'] as Map<String, dynamic>?;

    if (weight != null && height != null) {
      final heightInMeters = height / 100.0;
      setState(() {
        bmi = weight / (heightInMeters * heightInMeters);
        bmiCategory = _getBMICategory(bmi!);
        // Use stored diet plan if available, otherwise fetch a new one
        dietPlan = storedDietPlan != null
            ? storedDietPlan.map((key, value) => MapEntry(key, List<String>.from(value)))
            : {};
      });

      if (dietPlan.isEmpty) {
        _fetchAndStoreDietPlan();
      }
    }
  }
}

Future<void> _fetchAndStoreDietPlan() async {
  final OpenAIService openAIService = OpenAIService();
  final plan = await openAIService.getDietPlan(bmiCategory);

  if (plan.isNotEmpty) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'dietPlan': plan,
    });

    setState(() {
      dietPlan = plan;
    });
  }
}


  Future<void> _fetchDietPlan() async{
    final OpenAIService openAIService = OpenAIService();
    final plan = await openAIService.getDietPlan(bmiCategory);

    setState(() {
      dietPlan = plan.isNotEmpty ? plan : _getDietPlan(bmiCategory);
    });
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, List<String>> _getDietPlan(String category) {
    switch (category) {
      case 'Underweight':
        return {
          'Breakfast': [
            'Oatmeal with nuts and fruits',
            'Whole grain toast with avocado',
            'Protein smoothie with banana',
            '2 eggs with cheese'
          ],
          'Lunch': [
            'Chicken or fish with rice',
            'Pasta with meat sauce',
            'Sandwich with lean meat',
            'Quinoa bowl with beans'
          ],
          'Dinner': [
            'Salmon with sweet potato',
            'Lean beef with vegetables',
            'Turkey with brown rice',
            'Lentils with whole grains'
          ],
          'Snacks': [
            'Mixed nuts',
            'Greek yogurt with honey',
            'Protein bars',
            'Dried fruits'
          ]
        };

      case 'Normal':
        return {
          'Breakfast': [
            'Greek yogurt with berries',
            'Whole grain cereal with milk',
            'Fruit smoothie bowl',
            'Whole grain toast with eggs'
          ],
          'Lunch': [
            'Mixed salad with grilled chicken',
            'Whole grain wrap with turkey',
            'Quinoa bowl with vegetables',
            'Tuna sandwich on whole grain'
          ],
          'Dinner': [
            'Grilled fish with vegetables',
            'Chicken stir-fry with brown rice',
            'Lean meat with sweet potato',
            'Tofu with vegetables'
          ],
          'Snacks': [
            'Apple with almond butter',
            'Carrot sticks with hummus',
            'Trail mix',
            'Low-fat cheese'
          ]
        };

      case 'Overweight':
        return {
          'Breakfast': [
            'Egg white omelet with vegetables',
            'Steel-cut oats with berries',
            'Low-fat yogurt with fruits',
            'Whole grain toast with cottage cheese'
          ],
          'Lunch': [
            'Large salad with grilled chicken',
            'Vegetable soup with lean protein',
            'Quinoa with roasted vegetables',
            'Turkey lettuce wraps'
          ],
          'Dinner': [
            'Grilled fish with steamed vegetables',
            'Chicken breast with green salad',
            'Tofu stir-fry with brown rice',
            'Lean meat with roasted vegetables'
          ],
          'Snacks': [
            'Celery with low-fat cream cheese',
            'Apple slices',
            'Rice cakes',
            'Cucumber slices'
          ]
        };

      case 'Obese':
        return {
          'Breakfast': [
            'Protein smoothie with spinach',
            'Egg whites with vegetables',
            'Overnight oats with chia seeds',
            'Greek yogurt with berries'
          ],
          'Lunch': [
            'Large green salad with tuna',
            'Vegetable soup',
            'Grilled chicken with vegetables',
            'Zucchini noodles with turkey meatballs'
          ],
          'Dinner': [
            'Baked fish with steamed vegetables',
            'Lean protein with salad',
            'Cauliflower rice stir-fry',
            'Turkey breast with green vegetables'
          ],
          'Snacks': [
            'Celery sticks',
            'Cucumber slices with lemon',
            'Green tea',
            'Water with lemon'
          ]
        };

      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition Blueprint',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: bmi == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
                strokeWidth: 3,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blueAccent.withOpacity(0.1), Colors.white],
                  stops: [0.0, 0.3],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBMICard(),
                    SizedBox(height: 24),
                    _buildDietPlanHeader(),
                    SizedBox(height: 16),
                    ...dietPlan.entries.map(
                        (entry) => _buildMealSection(entry.key, entry.value)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBMICard() {
    Color categoryColor = _getBMICategoryColor(bmiCategory);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blueAccent, categoryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your BMI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    bmi!.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bmiCategory,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDietPlanHeader() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Daily Nutrition Plan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ElevatedButton.icon(
  onPressed: _fetchAndStoreDietPlan,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  icon: Icon(Icons.refresh, color: Colors.white, size: 20),
  label: Text(
    "Change",
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  ),
)

        ],
      ),
    );
  }

  Widget _buildMealSection(String mealTime, List<String> foods) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getMealIcon(mealTime),
                  color: Colors.blueAccent,
                ),
                SizedBox(width: 12),
                Text(
                  mealTime,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: index != foods.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        foods[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealTime) {
    switch (mealTime.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.restaurant_outlined;
      case 'dinner':
        return Icons.nights_stay_outlined;
      case 'snacks':
        return Icons.apple_outlined;
      default:
        return Icons.restaurant_menu;
    }
  }

  Color _getBMICategoryColor(String category) {
    switch (category) {
      case 'Underweight':
        return Colors.orange;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.deepOrange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.blueAccent;
    }
  }
}
