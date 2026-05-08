// ignore_for_file: file_names, use_build_context_synchronously

import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Createnewquestionnaier extends StatefulWidget {
  const Createnewquestionnaier({super.key});

  @override
  State<Createnewquestionnaier> createState() => _CreatenewquestionnaierState();
}

class _CreatenewquestionnaierState extends State<Createnewquestionnaier> {
  String? selectedEvaluationType;
  final TextEditingController questionController = TextEditingController();
  
  // 🔥 New state for the checkbox
  bool isCritical = false;

  final List<String> evaluationTypes = [
    'Teacher Evaluation',
    'Peer Evaluation',
    'Confidential Evaluation',
    'Society Chairperson',
    'Society Mentor'
  ];

  // 🔥 Changed to List of Maps to store question data and critical status
  final List<Map<String, dynamic>> questions = [];

  void addQuestion() {
    if (selectedEvaluationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select evaluation type')),
      );
      return;
    }

    if (questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a question')));
      return;
    }

    setState(() {
      // 🔥 Adding as an object to match backend expectations
      questions.add({
        "QuestionText": questionController.text.trim(),
        "IsCritical": isCritical,
      });
      questionController.clear();
      isCritical = false; // Reset checkbox after adding
    });
  }

  Future<void> saveToDatabase() async {
    if (selectedEvaluationType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select evaluation type')));
      return;
    }

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question')),
      );
      return;
    }

    // 🔥 Payload now contains list of objects
    final payload = {
      "EvaluationType": selectedEvaluationType,
      "Questions": questions,
    };

    try {
      final response = await http.post(
        Uri.parse('$Url/Questionnaire/Create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));

        setState(() {
          questions.clear();
          selectedEvaluationType = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Evaluation Questionnaire'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Dropdown
            const Text(
              'Select Evaluation Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedEvaluationType,
              items: evaluationTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedEvaluationType = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Choose evaluation type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Question Input
            const Text(
              'Enter Question',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                hintText: 'Type your question here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            // 🔥 Added Critical Checkbox Row
            Row(
              children: [
                Checkbox(
                  value: isCritical,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      isCritical = val!;
                    });
                  },
                ),
                const Text("Mark as Critical Question", 
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Questions List
            if (questions.isNotEmpty)
              Text(
                'Questions Added to Form (${questions.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return Card(
                    color: Colors.green.shade50,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: q["IsCritical"] ? Colors.red : Colors.green,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(q["QuestionText"]),
                      subtitle: q["IsCritical"] 
                        ? const Text("Critical", style: TextStyle(color: Colors.red, fontSize: 12)) 
                        : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            questions.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveToDatabase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Save & Publish Form',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}