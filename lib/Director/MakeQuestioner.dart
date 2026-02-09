import 'package:epams/Director/CreateNewQuestionnaier.dart';
import 'package:epams/Director/EditEvaluationQuestionnaire.dart';
import 'package:epams/Director/QuestionnaireModel.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== HEADER =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 4),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evaluation Questionnaires',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Manage and create evaluation forms for your institute',
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    Image.asset(
                      'assets/images/logo.jpeg',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// ===== GREEN INFO BAR =====
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2 Questionnaires Available',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context)=> const Createnewquestionnaier())
                            );
                          },
                          child: const Text(
                            '+ Create New',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ===== CARD 1 =====
                const QuestionnaireCard(
                  title: 'Teacher Evaluation - Fall 2025',
                  tag: 'Student',
                  tagColor: Colors.blue,
                  questions: 12,
                  // startDate: 'Nov 15, 2025',
                  // endDate: 'Dec 15, 2025',
                ),

                /// ===== CARD 2 =====
                const QuestionnaireCard(
                  title: 'Peer Review Form - Fall 2025',
                  tag: 'Peer',
                  tagColor: Colors.purple,
                  questions: 8,
                  // startDate: 'Nov 10, 2025',
                  // endDate: 'Dec 10, 2025',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// ================== CARD WIDGET =========================
/// =======================================================

class QuestionnaireCard extends StatelessWidget {
  final String title;
  final String tag;
  final Color tagColor;
  final int questions;
  // final String startDate;
  //final String endDate;

  const QuestionnaireCard({
    super.key,
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.questions,
    // required this.startDate,
    // required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE + QUESTIONS
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Questions',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                      Text(
                        questions.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// TAGS
            Row(
              children: [
                _chip(tag, tagColor),
                const SizedBox(width: 8),
                _chip('Active', Colors.green),
              ],
            ),

            const SizedBox(height: 10),

            /// DATES
            // Row(
            //   children: [
            //     const Icon(Icons.calendar_today,
            //         size: 14, color: Colors.grey),
            //     const SizedBox(width: 4),
            //     Text(
            //       'Start: $startDate',
            //       style: const TextStyle(fontSize: 12, color: Colors.grey),
            //     ),
            //     const SizedBox(width: 12),
            //     Text(
            //       'End: $endDate',
            //       style: const TextStyle(fontSize: 12, color: Colors.grey),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 12),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditQuestionnaireScreen(
                            questionnaire: QuestionnaireModel(
                              title: title,
                              type: tag,
                              questionsCount: questions,
                              questions: List.generate(
                                questions,
                                (index) =>
                                    'Sample question ${index + 1} for $title',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                // const SizedBox(width: 10),
                // Expanded(
                //   child: OutlinedButton.icon(
                //     onPressed: () {},
                //     icon: const Icon(Icons.calendar_month, size: 16),
                //     label: const Text('Set Dates'),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
