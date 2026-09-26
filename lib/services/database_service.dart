import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/program.dart';
import '../utils/reg_generator.dart';

// Local storage - replace with your backend / Firebase / Supabase
// No hard-coded data - all from user input

class DatabaseService {
  static const _kStudents = 'cc_students';
  static const _kPrograms = 'cc_programs';
  static const _kFaculties = 'cc_faculties';

  // Students
  Future<List<Student>> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStudents);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((e) => Student.fromJson(e)).toList();
  }

  Future<void> saveStudents(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(students.map((e) => e.toJson()).toList());
    await prefs.setString(_kStudents, raw);
  }

  Future<Student> addStudent({
    required String fullName,
    required String gender,
    required String programCode,
    required int enrollYear,
    required StudySession session,
    required String nationality,
    required String email,
    required String parentContact,
    required String classYear,
  }) async {
    final students = await getStudents();
    final existingRegNos = students.map((s) => s.regNo).toList();
    final nextSeq = RegGenerator.nextSeqForGroup(
      existingRegNos: existingRegNos,
      program: programCode,
      enrollYear: enrollYear,
      session: session,
    );
    final regNo = RegGenerator.generate(
      program: programCode,
      gender: gender,
      enrollYear: enrollYear,
      session: session,
      nationality: nationality,
      seq: nextSeq,
    );
    final student = Student(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      gender: gender,
      programCode: programCode,
      enrollYear: enrollYear,
      session: session,
      nationality: nationality,
      seq: nextSeq,
      regNo: regNo,
      email: email,
      parentContact: parentContact,
      classYear: classYear,
    );
    students.add(student);
    await saveStudents(students);
    return student;
  }

  // Programs - dynamic, no hard-code
  Future<List<Program>> getPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrograms);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((e) => Program.fromJson(e)).toList();
  }

  Future<void> savePrograms(List<Program> programs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrograms, jsonEncode(programs.map((e) => e.toJson()).toList()));
  }

  Future<List<Faculty>> getFaculties() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFaculties);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((e) => Faculty.fromJson(e)).toList();
  }

  Future<void> saveFaculties(List<Faculty> facs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFaculties, jsonEncode(facs.map((e) => e.toJson()).toList()));
  }

}
