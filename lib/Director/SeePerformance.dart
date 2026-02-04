import 'package:flutter/material.dart';

class Seeperformance extends StatefulWidget {
  const Seeperformance({super.key});

  @override
  State<Seeperformance> createState() => _SeeperformanceState();
}

class _SeeperformanceState extends State<Seeperformance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(12),
      child: Center(child: Text('SEE PERFRMANCE SCREEN')),
      ),
    );
  }
}