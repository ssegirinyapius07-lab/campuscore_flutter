import 'package:flutter/material.dart';
import '../utils/reg_generator.dart';

class RegPreviewWidget extends StatelessWidget {
  final String program;
  final String gender;
  final int enrollYear;
  final StudySession session;
  final String nationality;
  final int seq;
  const RegPreviewWidget({super.key, required this.program, required this.gender, required this.enrollYear, required this.session, required this.nationality, required this.seq});

  @override
  Widget build(BuildContext context) {
    final regNo = RegGenerator.generate(program: program, gender: gender, enrollYear: enrollYear, session: session, nationality: nationality, seq: seq);
    final yy = enrollYear.toString().substring(enrollYear.toString().length-2);
    final sCode = RegGenerator.sessionCode(session);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0A0A0F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Text('LIVE PREVIEW', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'monospace', fontSize: 22, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: program, style: const TextStyle(color: Color(0xFF60A5FA))),
                const TextSpan(text: '/', style: TextStyle(color: Colors.white24)),
                TextSpan(text: gender, style: const TextStyle(color: Colors.white70)),
                const TextSpan(text: '/', style: TextStyle(color: Colors.white24)),
                TextSpan(text: yy, style: const TextStyle(color: Color(0xFFFBBF24))),
                TextSpan(text: sCode, style: const TextStyle(color: Color(0xFFFDE68A))),
                const TextSpan(text: '/', style: TextStyle(color: Colors.white24)),
                TextSpan(text: nationality, style: const TextStyle(color: Color(0xFF34D399))),
                const TextSpan(text: '/', style: TextStyle(color: Colors.white24)),
                TextSpan(text: seq.toString().padLeft(3,'0'), style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _chip('$program = Program', const Color(0xFF60A5FA)),
              _chip('$gender = Gender', Colors.white70),
              _chip('$yy$sCode = $yy + ${RegGenerator.sessionLabel(session)}', const Color(0xFFFBBF24)),
              _chip('$nationality = Nationality', const Color(0xFF34D399)),
              _chip('${seq.toString().padLeft(3,'0')} = Personal No', Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          Text('$regNo  •  $yy$sCode contains year + session: D=Day, E=Evening, W=Weekend', style: const TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
