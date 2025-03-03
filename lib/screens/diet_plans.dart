import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      final weight = userDoc.data()?['weight'] as int?;
      final height = userDoc.data()?['height'] as int?;

      if (weight != null && height != null) {
        final heightInMeters = height / 100.0;
        setState(() {
          bmi = weight / (heightInMeters * heightInMeters);
          bmiCategory = _getBMICategory(bmi!);
          dietPlan = _getDietPlan(bmiCategory);
        });
      }
    }
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
        title: Text('Personalized Diet Plans', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: bmi == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your BMI: ${bmi!.toStringAsFixed(1)}',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Category: $bmiCategory',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Recommended Diet Plan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...dietPlan.entries.map((entry) => _buildMealSection(entry.key, entry.value)),
                ],
              ),
            ),
    );
  }

  Widget _buildMealSection(String mealTime, List<String> foods) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mealTime,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 8),
            ...foods.map((food) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.fiber_manual_record, size: 8),
                      SizedBox(width: 8),
                      Text(food, style: TextStyle(fontSize: 16)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
