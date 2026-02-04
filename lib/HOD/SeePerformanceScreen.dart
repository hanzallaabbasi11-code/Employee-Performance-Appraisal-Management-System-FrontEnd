import 'package:flutter/material.dart';

class SeePerformanceScreen extends StatefulWidget {
  const SeePerformanceScreen({super.key});

  @override
  State<SeePerformanceScreen> createState() => _SeePerformanceScreenState();
}

class _SeePerformanceScreenState extends State<SeePerformanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(12),
      child: Center(child: Text('See Perfromance screen'),),),
    );
  }
}