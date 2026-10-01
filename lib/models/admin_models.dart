class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalUsers, required this.students, required this.lecturers,
    required this.parents, required this.admins, required this.faculties,
    required this.programs, required this.programLevels, required this.courseUnits,
    required this.academicYears, required this.semesters,
  });
  final int totalUsers, students, lecturers, parents, admins;
  final int faculties, programs, programLevels, courseUnits, academicYears, semesters;

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    final users = (json['user'] as Map<String, dynamic>?) ?? {};
    final academics = (json['academics'] as Map<String, dynamic>?) ?? {};
    int read(Map<String, dynamic> source, String key) => (source[key] as num?)?.toInt() ?? 0;
    return AdminDashboardStats(
      totalUsers: read(users, 'total'), students: read(users, 'students'),
      lecturers: read(users, 'lecturers'), parents: read(users, 'parents'),
      admins: read(users, 'admins'), faculties: read(academics, 'faculties'),
      programs: read(academics, 'programs'), programLevels: read(academics, 'program_levels'),
      courseUnits: read(academics, 'course_units'), academicYears: read(academics, 'academic_years'),
      semesters: read(academics, 'semesters'),
    );
  }
}

class AdminFaculty {
  const AdminFaculty({required this.id, required this.code, required this.name, required this.description});
  final int id; final String code; final String name; final String description;
  factory AdminFaculty.fromJson(Map<String, dynamic> json) => AdminFaculty(
    id: (json['id'] as num?)?.toInt() ?? 0, code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '', description: json['description'] as String? ?? '',
  );
}

class AdminProgramLevel {
  const AdminProgramLevel({required this.id, required this.code, required this.name, required this.description, required this.isActive});
  final int id; final String code; final String name; final String description; final bool isActive;
  factory AdminProgramLevel.fromJson(Map<String, dynamic> json) => AdminProgramLevel(
    id: (json['id'] as num?)?.toInt() ?? 0, code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '', description: json['description'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? true,
  );
}

class AdminProgram {
  const AdminProgram({required this.id, required this.code, required this.name, required this.durationYears, required this.description, required this.isActive, required this.faculty, required this.level});
  final int id; final String code; final String name; final int durationYears; final String description; final bool isActive;
  final AdminFaculty faculty; final AdminProgramLevel level;
  factory AdminProgram.fromJson(Map<String, dynamic> json) => AdminProgram(
    id: (json['id'] as num?)?.toInt() ?? 0, code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '', durationYears: (json['duration_years'] as num?)?.toInt() ?? 0,
    description: json['description'] as String? ?? '', isActive: json['is_active'] as bool? ?? true,
    faculty: AdminFaculty.fromJson((json['faculty'] as Map<String, dynamic>?) ?? {}),
    level: AdminProgramLevel.fromJson((json['level'] as Map<String, dynamic>?) ?? {}),
  );
}