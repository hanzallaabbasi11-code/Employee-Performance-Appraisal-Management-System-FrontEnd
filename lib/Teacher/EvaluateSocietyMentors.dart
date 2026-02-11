import 'package:flutter/material.dart';

class Evaluatesocietymentors extends StatefulWidget {
  const Evaluatesocietymentors({super.key});

  @override
  State<Evaluatesocietymentors> createState() => _EvaluatesocietymentorsState();
}

class _EvaluatesocietymentorsState extends State<Evaluatesocietymentors> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Evaluate Society Mentors")),
      body: Center(child: Text("Evaluate Your Society Mentors")),
    );
  }
}