class TeacherCourseResponse {
  final String teacherId;
  final String teacherName;
  final List<EnrolledCourse> courses;

  TeacherCourseResponse({
    required this.teacherId,
    required this.teacherName,
    required this.courses,
  });

  factory TeacherCourseResponse.fromJson(Map<String, dynamic> json) {
    return TeacherCourseResponse(
      teacherId: json['TeacherID'],
      teacherName: json['TeacherName'],
      courses: (json['EnrolledCourses'] as List)
          .map((c) => EnrolledCourse.fromJson(c))
          .toList(),
    );
  }
}

class EnrolledCourse {
  final String id;
  final String course;
  final String code;

  EnrolledCourse({
    required this.id,
    required this.course,
    required this.code,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    return EnrolledCourse(
      id: json['Id'],
      course: json['Course'],
      code: json['Code'],
    );
  }
}