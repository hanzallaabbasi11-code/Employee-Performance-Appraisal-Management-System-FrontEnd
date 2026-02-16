class TeacherModel {
  final String teacherID;
  final String teacherName;
  final List<String> courses;

  TeacherModel({
    required this.teacherID,
    required this.teacherName,
    required this.courses,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      teacherID: json['TeacherID'],
      teacherName: json['TeacherName'] ?? '',
      courses: List<String>.from(json['Courses'] ?? []),
    );
  }
}
