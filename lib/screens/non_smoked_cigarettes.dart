import 'package:flutter/material.dart';

class NonSmokedCigarettesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Non-Smoked Cigarettes'),
      ),
      body: Center(
        child: Text('Track the cigarettes you didn’t smoke here.'),
      ),
    );
  }
}
