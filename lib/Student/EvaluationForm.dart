import 'package:flutter/material.dart';

class Evaluationform extends StatefulWidget {
  const Evaluationform({super.key});

  @override
  State<Evaluationform> createState() => _EvaluationformState();
}

class _EvaluationformState extends State<Evaluationform> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child:Padding(padding: EdgeInsets.all(12),
        child:Column(
             children: [
              Row(
                children: [
                  IconButton(onPressed: ()=> Navigator.pop(context), icon:Icon(Icons.arrow_back)),
                  Text('Back to Courses',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ],
              ),
              const SizedBox(height: 15,),
              Container(
                height: 100,
                width: 500,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                
                  children: [
                    SizedBox(height: 5,),
                    Container(
                     color: Colors.white,
                     child:Text('CS-301'),
                    )
                  ],
                ),
              ),
             ],
        ) ,) ,
      )),
    );
  }
}