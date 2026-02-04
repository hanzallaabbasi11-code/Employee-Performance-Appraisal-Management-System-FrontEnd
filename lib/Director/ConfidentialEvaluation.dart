import 'package:flutter/material.dart';

class Confidentialevaluation extends StatefulWidget {
  const Confidentialevaluation({super.key});

  @override
  State<Confidentialevaluation> createState() => _ConfidentialevaluationState();
}

class _ConfidentialevaluationState extends State<Confidentialevaluation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(12),
      child: Center(child: Text('Confidential Evaluation Screen'),),),
    );
  }
}