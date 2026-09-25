import '../utils/reg_generator.dart';

class Student {
  String id;
  String fullName;
  String gender; // M or F
  String programCode; // BACS
  int enrollYear; // 2025
  StudySession session; // day/evening/weekend
  String nationality; // UG
  int seq;
  String regNo; // BACS/M/25D/UG/001 - generated
  String email;
  String parentContact;
  String classYear; // Year 1,2,3

  Student({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.programCode,
    required this.enrollYear,
    required this.session,
    required this.nationality,
    required this.seq,
    required this.regNo,
    required this.email,
    required this.parentContact,
    required this.classYear,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'gender': gender,
    'programCode': programCode,
    'enrollYear': enrollYear,
    'session': session.index,
    'nationality': nationality,
    'seq': seq,
    'regNo': regNo,
    'email': email,
    'parentContact': parentContact,
    'classYear': classYear,
  };

  factory Student.fromJson(Map<String, dynamic> j) => Student(
    id: j['id'],
    fullName: j['fullName'],
    gender: j['gender'],
    programCode: j['programCode'],
    enrollYear: j['enrollYear'],
    session: StudySession.values[j['session']],
    nationality: j['nationality'],
    seq: j['seq'],
    regNo: j['regNo'],
    email: j['email'],
    parentContact: j['parentContact'],
    classYear: j['classYear'],
  );
}
