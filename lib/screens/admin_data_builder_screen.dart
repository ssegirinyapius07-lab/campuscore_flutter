import 'package:flutter/material.dart';
import '../utils/reg_generator.dart';
import '../widgets/reg_preview_widget.dart';
import '../services/database_service.dart';
import '../models/program.dart';

class AdminDataBuilderScreen extends StatefulWidget {
  const AdminDataBuilderScreen({super.key});
  @override
  State<AdminDataBuilderScreen> createState() => _AdminDataBuilderScreenState();
}

class _AdminDataBuilderScreenState extends State<AdminDataBuilderScreen> {
  String program = '';
  String gender = 'M';
  int year = DateTime.now().year;
  StudySession session = StudySession.day;
  String nationality = '';
  int seq = 1;

  List<Program> programs = [];
  List<Faculty> faculties = [];
  final db = DatabaseService();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final parentContactCtrl = TextEditingController();
  final classYearCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final seqCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    yearCtrl.text = year.toString();
    seqCtrl.text = seq.toString();
    _load();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    parentContactCtrl.dispose();
    classYearCtrl.dispose();
    yearCtrl.dispose();
    seqCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await db.getPrograms();
    final f = await db.getFaculties();
    if (!mounted) return;
    setState(() {
      programs = p;
      faculties = f;
      if (p.isNotEmpty) program = p.first.code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Data Structure Builder'),
          backgroundColor: Colors.white),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE))),
                child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Registration format: PROGRAM/GENDER/YY+SESSION/NATIONALITY/SEQ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(height: 4),
                      Text(
                          'The generated registration number uses the selected program, gender, enrollment year, session, nationality, and sequence.',
                          style: TextStyle(fontSize: 12, color: Colors.black54))
                    ])),
            const SizedBox(height: 16),
            RegPreviewWidget(
                program: program,
                gender: gender,
                enrollYear: year,
                session: session,
                nationality: nationality,
                seq: seq),
            const SizedBox(height: 20),
            const Text('Configure Blocks',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildProgramSelector(),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildGender(),
                      const SizedBox(height: 12),
                      _buildYear(),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: _buildGender()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildYear()),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSessionSelector(),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildNationality(),
                      const SizedBox(height: 12),
                      _buildSeq(),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: _buildNationality()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSeq()),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Add Student with this Format',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white)),
            const SizedBox(height: 12),
            TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white)),
            const SizedBox(height: 12),
            TextField(
                controller: parentContactCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: 'Parent Contact',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white)),
            const SizedBox(height: 12),
            TextField(
                controller: classYearCtrl,
                decoration: InputDecoration(
                    labelText: 'Class / Year of Study',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white)),
            const SizedBox(height: 12),
            SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1B4B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          emailCtrl.text.trim().isEmpty ||
                          parentContactCtrl.text.trim().isEmpty ||
                          classYearCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Complete all student details first.')));
                        return;
                      }
                      final s = await db.addStudent(
                          fullName: nameCtrl.text.trim(),
                          gender: gender,
                          programCode: program,
                          enrollYear: year,
                          session: session,
                          nationality: nationality,
                          email: emailCtrl.text.trim(),
                          parentContact: parentContactCtrl.text.trim(),
                          classYear: classYearCtrl.text.trim());
                      if (!mounted) return;
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${s.regNo}')));
                      nameCtrl.clear();
                      emailCtrl.clear();
                      parentContactCtrl.clear();
                      classYearCtrl.clear();
                    },
                    child: const Text('Add Student - Auto Generate Reg No',
                        style: TextStyle(color: Colors.white)))),
            const SizedBox(height: 24),
            const Text('Faculties & Programs (Your Own Tables)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...faculties.map((f) => ListTile(
                title: Text(f.name),
                subtitle: Text(f.id),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 8),
            ...programs.map((p) => ListTile(
                title: Text('${p.code} - ${p.name}'),
                subtitle: Text('Faculty: ${p.facultyId}'),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                    title: const Text('Add Program'),
                                    content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                              decoration: InputDecoration(
                                                  labelText: 'Program Code')),
                                          TextField(
                                              decoration: InputDecoration(
                                                  labelText: 'Name'))
                                        ]),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Add'))
                                    ]));
                      },
                      child: const Text('Add Program')))
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramSelector() => DropdownButtonFormField<String>(
      initialValue: programs.any((item) => item.code == program) ? program : null,
      decoration: InputDecoration(
          labelText: 'Program Code',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white),
      items: programs
          .map((e) => DropdownMenuItem(value: e.code, child: Text(e.code)))
          .toList(),
      onChanged: (v) => setState(() => program = v!));

  Widget _buildGender() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Gender M/F',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: ChoiceChip(
                  label: const Text('M'),
                  selected: gender == 'M',
                  onSelected: (_) => setState(() => gender = 'M'))),
          const SizedBox(width: 8),
          Expanded(
              child: ChoiceChip(
                  label: const Text('F'),
                  selected: gender == 'F',
                  onSelected: (_) => setState(() => gender = 'F')))
        ])
      ]);

  Widget _buildYear() => TextField(
      decoration: InputDecoration(
          labelText: 'Enrollment Year',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.number,
      controller: yearCtrl,
      onChanged: (v) {
        final y = int.tryParse(v);
        if (y != null) setState(() => year = y);
      });

  Widget _buildSessionSelector() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Study Session',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
            children: StudySession.values.map((s) {
          final code = RegGenerator.sessionCode(s);
          final label = RegGenerator.sessionLabel(s);
          final selected = session == s;
          return Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                      label: Text('$label ($code)'),
                      selected: selected,
                      onSelected: (_) => setState(() => session = s),
                      selectedColor: const Color(0xFFF59E0B))));
        }).toList())
      ]);

  Widget _buildNationality() => DropdownButtonFormField<String>(
      initialValue: nationality.isEmpty ? null : nationality,
      decoration: InputDecoration(
          labelText: 'Nationality',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white),
      items: const [
        'UG', 'KE', 'TZ', 'RW', 'SS', 'NG', 'GH'
      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => setState(() => nationality = v!));

  Widget _buildSeq() => TextField(
      decoration: InputDecoration(
          labelText: 'Sequence Number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.number,
      controller: seqCtrl,
      onChanged: (v) {
        final s = int.tryParse(v);
        if (s != null) setState(() => seq = s);
      });
}
