class QuestionnaireModel {
  final String title;
  final String type;
  final int questionsCount;
  final List<String> questions;

  QuestionnaireModel({
    required this.title,
    required this.type,
    required this.questionsCount,
    required this.questions,
  });
}
