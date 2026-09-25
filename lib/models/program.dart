class Program {
  String code; // BACS
  String name; // Bachelor of Arts in Computer Science
  String facultyId;
  Program({required this.code, required this.name, required this.facultyId});
  Map<String, dynamic> toJson() => {'code': code, 'name': name, 'facultyId': facultyId};
  factory Program.fromJson(Map<String, dynamic> j) => Program(code: j['code'], name: j['name'], facultyId: j['facultyId']);
}

class Faculty {
  String id;
  String name;
  Faculty({required this.id, required this.name});
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory Faculty.fromJson(Map<String, dynamic> j) => Faculty(id: j['id'], name: j['name']);
}

class CourseUnit {
  String code; // CSC2101
  String name; // Data Structures
  String programCode; // BACS
  String classYear; // Year 2
  String semester; // Sem 1
  String lecturerId;
  CourseUnit({required this.code, required this.name, required this.programCode, required this.classYear, required this.semester, required this.lecturerId});
  Map<String, dynamic> toJson() => {'code': code, 'name': name, 'programCode': programCode, 'classYear': classYear, 'semester': semester, 'lecturerId': lecturerId};
  factory CourseUnit.fromJson(Map<String, dynamic> j) => CourseUnit(code: j['code'], name: j['name'], programCode: j['programCode'], classYear: j['classYear'], semester: j['semester'], lecturerId: j['lecturerId']);
}
