import 'dart:convert';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditQuestionnaireScreen extends StatefulWidget {
  final int questionnaireId;

  const EditQuestionnaireScreen({super.key, required this.questionnaireId});

  @override
  State<EditQuestionnaireScreen> createState() =>
      _EditQuestionnaireScreenState();
}

class QuestionItem {
  int id; // 0 for new questions
  String text;

  QuestionItem({required this.id, required this.text});
}

class _EditQuestionnaireScreenState extends State<EditQuestionnaireScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController evaluationTypeController = TextEditingController();
  final TextEditingController newQuestionController = TextEditingController();

  List<QuestionItem> questions = [];
  List<int> deletedIds = [];
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  /// 🔹 FETCH FULL QUESTIONNAIRE BY ID
  Future<void> loadQuestionnaire() async {
    final response = await http.get(
      Uri.parse("$Url/Questionnaire/GetById/${widget.questionnaireId}"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        titleController.text = data['title'] ?? '';
        evaluationTypeController.text = data['evaluationType'] ?? '';
        questions = (data['questions'] as List)
            .map((q) => QuestionItem(id: q['id'], text: q['questionText']))
            .toList();
        loading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load questionnaire. Status: ${response.statusCode}",
          ),
        ),
      );
    }
  }

  /// 🔹 SAVE ALL CHANGES
  Future<void> saveChanges() async {
    if (titleController.text.isEmpty || evaluationTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Evaluation Type cannot be empty")),
      );
      return;
    }

    setState(() => saving = true);

    final payload = {
      "QuestionnaireId": widget.questionnaireId,
      "Title": titleController.text,
      "Type": evaluationTypeController.text,
      "DeletedIds": deletedIds,
      "Questions": questions
          .map((q) => {"Id": q.id, "QuestionText": q.text})
          .toList(),
    };

    final response = await http.post(
      Uri.parse("$Url/Questionnaire/SaveAllChanges"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    setState(() => saving = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Questionnaire saved successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit Evaluation Questionnaire'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// INFO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Make changes and click Save when done',
                style: TextStyle(color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),

            /// TITLE
            const Text('Questionnaire Title', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            /// EVALUATION TYPE
            const Text('Evaluation Type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: evaluationTypeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter evaluation type',
              ),
            ),
            const SizedBox(height: 16),

            /// ADD QUESTION
            const Text('Add Question', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: newQuestionController,
                    decoration: const InputDecoration(
                      hintText: 'Type your question here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (newQuestionController.text.isNotEmpty) {
                      setState(() {
                        questions.add(QuestionItem(id: 0, text: newQuestionController.text));
                        newQuestionController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('+', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// QUESTIONS LIST
            Text('Questions (${questions.length})', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final questionController = TextEditingController(text: q.text);

                return Card(
                  color: Colors.green.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: questionController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              q.text = val;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (q.id != 0) deletedIds.add(q.id);
                              questions.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
