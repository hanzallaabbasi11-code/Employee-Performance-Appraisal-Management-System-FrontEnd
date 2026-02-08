import 'package:epams/Director/QuestionnaireModel.dart';
import 'package:flutter/material.dart';

class EditQuestionnaireScreen extends StatefulWidget {
  final QuestionnaireModel questionnaire;

  const EditQuestionnaireScreen({
    super.key,
    required this.questionnaire,
  });

  @override
  State<EditQuestionnaireScreen> createState() =>
      _EditQuestionnaireScreenState();
}

class _EditQuestionnaireScreenState
    extends State<EditQuestionnaireScreen> {
  late TextEditingController titleController;
  late TextEditingController questionController;

  late List<String> questions;

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.questionnaire.title);
    questionController = TextEditingController();
    questions = List.from(widget.questionnaire.questions);
  }

  @override
  Widget build(BuildContext context) {
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
                'Edit your evaluation form details',
                style: TextStyle(color: Colors.green),
              ),
            ),

            const SizedBox(height: 16),

            /// TITLE
            const Text('Questionnaire Title'),
            const SizedBox(height: 6),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// TYPE
            const Text('Select Evaluation Type'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: widget.questionnaire.type,
              items: const [
                DropdownMenuItem(
                    value: 'Student', child: Text('Student')),
                DropdownMenuItem(
                    value: 'Teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'Peer', child: Text('Peer')),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// ADD QUESTION
            const Text('Enter Question'),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      hintText: 'Type your question here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (questionController.text.isNotEmpty) {
                      setState(() {
                        questions.add(questionController.text);
                        questionController.clear();
                      });
                    }
                  },
                  child: const Text('+ Add'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// QUESTIONS LIST
            Text('Questions Added to Form (${questions.length})'),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.green.shade50,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text('${index + 1}',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(questions[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
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
          ],
        ),
      ),
    );
  }
}
