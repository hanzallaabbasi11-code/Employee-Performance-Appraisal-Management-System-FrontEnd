class QuestionnaireModel {
  final int id;
  final String type;
  final String flag;
  final List<Question> questions;

  QuestionnaireModel({
    required this.id,
    required this.type,
    required this.flag,
    required this.questions,
  });

  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModel(
      id: int.parse(json['QuestionareID'].toString()),  // ✅ SAFE
      type: json['Type'] ?? "",
      flag: json['Flag'] ?? "",
      questions: (json['Questions'] as List)
          .map((e) => Question.fromJson(e))
          .toList(),
    );
  }
}

class Question {
  final int questionID;
  final String questionText;

  Question({
    required this.questionID,
    required this.questionText,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionID: int.parse(json['QuestionID'].toString()), // ✅ SAFE
      questionText: json['QuestionText'] ?? "",
    );
  }
}
