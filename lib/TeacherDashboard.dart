import 'package:flutter/material.dart';

class Teacherdashboard extends StatefulWidget {
  const Teacherdashboard({super.key});

  @override
  State<Teacherdashboard> createState() => _TeacherdashboardState();
}

class _TeacherdashboardState extends State<Teacherdashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Teacher Dashboard')),
    );
  }
}