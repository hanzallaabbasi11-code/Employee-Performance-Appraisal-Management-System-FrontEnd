import 'package:flutter/material.dart';

class Addkpi extends StatefulWidget {
  const Addkpi({super.key});

  @override
  State<Addkpi> createState() => _AddkpiState();
}

class _AddkpiState extends State<Addkpi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(12),
      child: Center(child: Text('Add kpi Screen')),),
    );
  }
}