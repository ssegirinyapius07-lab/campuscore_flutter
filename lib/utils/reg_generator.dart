// Your exact format: BACS/M/25D/UG/001
// 25D contains year of enrollment and study session
// D = Day, E = Evening, W = Weekend

enum StudySession { day, evening, weekend }

class RegGenerator {
  static String sessionCode(StudySession s) {
    switch (s) {
      case StudySession.day: return 'D';
      case StudySession.evening: return 'E';
      case StudySession.weekend: return 'W';
    }
  }

  static StudySession sessionFromCode(String code) {
    switch (code) {
      case 'D': return StudySession.day;
      case 'E': return StudySession.evening;
      case 'W': return StudySession.weekend;
      default: return StudySession.day;
    }
  }

  static String sessionLabel(StudySession s) {
    switch (s) {
      case StudySession.day: return 'Day';
      case StudySession.evening: return 'Evening';
      case StudySession.weekend: return 'Weekend';
    }
  }

  // Core function: BACS/M/25D/UG/001
  static String generate({
    required String program, // BACS
    required String gender, // M or F
    required int enrollYear, // 2025
    required StudySession session, // day/evening/weekend
    required String nationality, // UG
    required int seq, // 1
  }) {
    final yy = enrollYear.toString().substring(enrollYear.toString().length - 2); // 25
    final sCode = sessionCode(session); // D
    final seqStr = seq.toString().padLeft(3, '0'); // 001
    return '$program/$gender/$yy$sCode/$nationality/$seqStr';
  }

  // Parse back for filtering
  static Map<String, String> parse(String regNo) {
    // BACS/M/25D/UG/001 -> parts
    try {
      final parts = regNo.split('/');
      if (parts.length != 5) return {};
      final yySession = parts[2]; // 25D
      final yy = yySession.substring(0, yySession.length - 1);
      final sCode = yySession.substring(yySession.length - 1);
      return {
        'program': parts[0],
        'gender': parts[1],
        'yy': yy,
        'sessionCode': sCode,
        'nationality': parts[3],
        'seq': parts[4],
      };
    } catch (e) {
      return {};
    }
  }

  // Auto-increment logic: counts existing per PROGRAM+YY+SESSION group
  static int nextSeqForGroup({
    required List<String> existingRegNos,
    required String program,
    required int enrollYear,
    required StudySession session,
  }) {
    final yy = enrollYear.toString().substring(enrollYear.toString().length - 2);
    final sCode = sessionCode(session);
    final count = existingRegNos.where((r) {
      final p = parse(r);
      return p['program'] == program && p['yy'] == yy && p['sessionCode'] == sCode;
    }).length;
    return count + 1;
  }
}
