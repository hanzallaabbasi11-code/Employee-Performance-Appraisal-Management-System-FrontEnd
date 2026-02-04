class EnrollmentCourse {
  final int id;
  final String teacher;
  final String course;
  final String code;

  EnrollmentCourse({
    required this.id,
    required this.teacher,
    required this.course,
    required this.code,
  });

  factory EnrollmentCourse.fromJson(Map<String, dynamic> json) {
    return EnrollmentCourse(
      id: json['id'],
      teacher: json['teacher'],
      course: json['course'],
      code: json['code'],
    );
  }
}
