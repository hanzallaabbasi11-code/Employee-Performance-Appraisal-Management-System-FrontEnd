import 'package:flutter/material.dart';

class Makequestioner extends StatefulWidget {
  const Makequestioner({super.key});

  @override
  State<Makequestioner> createState() => _MakequestionerState();
}

class _MakequestionerState extends State<Makequestioner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(12),
      child: Center(child: Text('Make Questioner screen')),),
    );
  }
}