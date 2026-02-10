class QuestionnaireModel {
  final int id;
  final String type;
  final int questionsCount;
  bool isActive; // derived from flag

  QuestionnaireModel({
    required this.id,
    required this.type,
    required this.questionsCount,
    required this.isActive,
  });

  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModel(
      id: json['Id'],
      type: json['Type'],
      questionsCount: json['QuestionCount'],
      isActive: json['Flag'] == "1",
    );
  }
}
