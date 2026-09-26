class StudentDashboard {
  const StudentDashboard({required this.student, required this.courses, required this.attendance, required this.assessments});
  final StudentSummary student;
  final List<CourseSummary> courses;
  final AttendanceSummary attendance;
  final List<AssessmentSummary> assessments;

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    final studentJson = Map<String, dynamic>.from(json['student'] as Map? ?? {});
    final coursesJson = json['courses'] as List? ?? const [];
    final assessmentsJson = json['assessments'] as List? ?? const [];
    return StudentDashboard(
      student: StudentSummary.fromJson(studentJson),
      courses: coursesJson.whereType<Map>().map((item) => CourseSummary.fromJson(Map<String, dynamic>.from(item))).toList(),
      attendance: AttendanceSummary.fromJson(Map<String, dynamic>.from(json['attendance'] as Map? ?? {})),
      assessments: assessmentsJson.whereType<Map>().map((item) => AssessmentSummary.fromJson(Map<String, dynamic>.from(item))).toList(),
    );
  }
}

class StudentSummary {
  const StudentSummary({required this.fullName, required this.username, required this.email, required this.admissionNumber, required this.programName, required this.programCode, required this.facultyName, required this.yearOfStudy, required this.session});
  final String fullName, username, email, admissionNumber, programName, programCode, facultyName, session;
  final int yearOfStudy;

  factory StudentSummary.fromJson(Map<String, dynamic> json) {
    final program = Map<String, dynamic>.from(json['program'] as Map? ?? {});
    final faculty = Map<String, dynamic>.from(program['faculty'] as Map? ?? {});
    return StudentSummary(
      fullName: json['full_name'] as String? ?? '', username: json['username'] as String? ?? '', email: json['email'] as String? ?? '',
      admissionNumber: json['admission_number'] as String? ?? '', programName: program['name'] as String? ?? '', programCode: program['code'] as String? ?? '',
      facultyName: faculty['name'] as String? ?? '', yearOfStudy: (json['year_of_study'] as num?)?.toInt() ?? 0, session: json['session'] as String? ?? '',
    );
  }
}

class CourseSummary {
  const CourseSummary({required this.code, required this.name, required this.creditUnits});
  final String code, name;
  final int creditUnits;
  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    final course = Map<String, dynamic>.from(json['course'] as Map? ?? json);
    return CourseSummary(code: course['code'] as String? ?? '', name: course['name'] as String? ?? '', creditUnits: (course['credit_units'] as num?)?.toInt() ?? 0);
  }
}

class AttendanceSummary {
  const AttendanceSummary({required this.total, required this.present, required this.absent, required this.late, required this.percentage});
  final int total, present, absent, late;
  final double percentage;
  factory AttendanceSummary.fromJson(Map<String, dynamic> json) => AttendanceSummary(total: (json['total'] as num?)?.toInt() ?? 0, present: (json['present'] as num?)?.toInt() ?? 0, absent: (json['absent'] as num?)?.toInt() ?? 0, late: (json['late'] as num?)?.toInt() ?? 0, percentage: (json['percentage'] as num?)?.toDouble() ?? 0);
}

class AssessmentSummary {
  const AssessmentSummary({required this.name, required this.score});
  final String name;
  final double? score;
  factory AssessmentSummary.fromJson(Map<String, dynamic> json) => AssessmentSummary(name: json['name'] as String? ?? json['title'] as String? ?? 'Assessment', score: (json['score'] as num?)?.toDouble());
}