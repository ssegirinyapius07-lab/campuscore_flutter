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

class AdminStudent {
  const AdminStudent({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.isActive,
    required this.admissionNumber,
    required this.program,
    required this.gender,
    required this.nationality,
    required this.enrollmentYear,
    required this.session,
    required this.parentContact,
    required this.yearOfStudy,
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final bool isActive;
  final String admissionNumber;
  final AdminStudentProgram? program;
  final String gender;
  final String nationality;
  final int? enrollmentYear;
  final String session;
  final String parentContact;
  final int yearOfStudy;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? username : name;
  }

  factory AdminStudent.fromJson(Map<String, dynamic> json) => AdminStudent(
    id: (json['id'] as num?)?.toInt() ?? 0,
    username: json['username'] as String? ?? '',
    email: json['email'] as String? ?? '',
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? false,
    admissionNumber: json['admission_number'] as String? ?? '',
    program: json['program'] is Map<String, dynamic>
        ? AdminStudentProgram.fromJson(json['program'] as Map<String, dynamic>)
        : null,
    gender: json['gender'] as String? ?? '',
    nationality: json['nationality'] as String? ?? '',
    enrollmentYear: (json['enrollment_year'] as num?)?.toInt(),
    session: json['session'] as String? ?? '',
    parentContact: json['parent_contact'] as String? ?? '',
    yearOfStudy: (json['year_of_study'] as num?)?.toInt() ?? 1,
  );
}

class AdminStudentProgram {
  const AdminStudentProgram({
    required this.id,
    required this.code,
    required this.name,
  });

  final int id;
  final String code;
  final String name;

  factory AdminStudentProgram.fromJson(Map<String, dynamic> json) =>
      AdminStudentProgram(
        id: (json['id'] as num?)?.toInt() ?? 0,
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );
}
