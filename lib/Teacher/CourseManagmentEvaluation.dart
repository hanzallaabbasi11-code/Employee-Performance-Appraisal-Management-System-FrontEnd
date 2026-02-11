import 'package:flutter/material.dart';

class Coursemanagmentevaluation extends StatefulWidget {
  const Coursemanagmentevaluation({super.key});

  @override
  State<Coursemanagmentevaluation> createState() => _CoursemanagmentevaluationState();
}

class _CoursemanagmentevaluationState extends State<Coursemanagmentevaluation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Course Managment Evaluation")),
      body: Center(child: Text("View HOD Evaluations")),
    );
  }
}