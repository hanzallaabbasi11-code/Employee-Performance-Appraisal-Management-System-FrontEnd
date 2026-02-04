import 'package:flutter/material.dart';

class Addpeerevaluators extends StatefulWidget {
  const Addpeerevaluators({super.key});

  @override
  State<Addpeerevaluators> createState() => _AddpeerevaluatorsState();
}

class _AddpeerevaluatorsState extends State<Addpeerevaluators> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(12),
      child: Center(child: Text('Add Peer Evaluator Screen'),),),
    );
  }
}