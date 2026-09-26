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
  String program = 'BACS';
  String gender = 'M';
  int year = 2025;
  StudySession session = StudySession.day;
  String nationality = 'UG';
  int seq = 1;

  List<Program> programs = [];
  List<Faculty> faculties = [];
  final db = DatabaseService();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await db.getPrograms();
    final f = await db.getFaculties();
    if (!mounted) return;
    setState((){ programs=p; faculties=f; if(p.isNotEmpty) program=p.first.code; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Structure Builder'), backgroundColor: Colors.white),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBFDBFE))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your Format: PROGRAM/GENDER/YY+SESSION/NATIONALITY/SEQ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), SizedBox(height: 4), Text('Example: BACS/M/25D/UG/001 where 25D = 2025 Day (D=Day, E=Evening, W=Weekend)', style: TextStyle(fontSize: 12, color: Colors.black54))])),

            const SizedBox(height: 16),
            RegPreviewWidget(program: program, gender: gender, enrollYear: year, session: session, nationality: nationality, seq: seq),

            const SizedBox(height: 20),
            const Text('Configure Blocks', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildProgramSelector(),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _buildGender()), const SizedBox(width: 12), Expanded(child: _buildYear())]),
            const SizedBox(height: 12),
            _buildSessionSelector(),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _buildNationality()), const SizedBox(width: 12), Expanded(child: _buildSeq())]),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Add Student with this Format', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1B4B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () async {
              final s = await db.addStudent(fullName: nameCtrl.text, gender: gender, programCode: program, enrollYear: year, session: session, nationality: nationality, email: emailCtrl.text, parentContact: '+256700000000', classYear: 'Year 2');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${s.regNo}')));
              nameCtrl.clear(); emailCtrl.clear();
            }, child: const Text('Add Student - Auto Generate Reg No', style: TextStyle(color: Colors.white)))),

            const SizedBox(height: 24),
            const Text('Faculties & Programs (Your Own Tables)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...faculties.map((f) => ListTile(title: Text(f.name), subtitle: Text(f.id), tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 8),
            ...programs.map((p) => ListTile(title: Text('${p.code} - ${p.name}'), subtitle: Text('Faculty: ${p.facultyId}'), tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () async { await db.loadExampleData(); if (!mounted) return; await _load(); if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loaded example BACS/M/25D/UG/001 format data'))); }, child: const Text('Load Example Data'))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(onPressed: (){ showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Add Program'), content: Column(mainAxisSize: MainAxisSize.min, children: [const TextField(decoration: InputDecoration(labelText: 'Code e.g. BACS')), const TextField(decoration: InputDecoration(labelText: 'Name'))]), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Add'))])); }, child: const Text('Add Program')))
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramSelector() => DropdownButtonFormField<String>(initialValue: programs.isEmpty ? null : program, decoration: InputDecoration(labelText: 'Program Code e.g. BACS', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white), items: (programs.isEmpty ? ['BACS','BIT','BBA'] : programs.map((e)=>e.code).toList()).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(()=>program=v!));

  Widget _buildGender() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Gender M/F', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Row(children: [Expanded(child: ChoiceChip(label: const Text('M'), selected: gender=='M', onSelected: (_)=>setState(()=>gender='M'))), const SizedBox(width: 8), Expanded(child: ChoiceChip(label: const Text('F'), selected: gender=='F', onSelected: (_)=>setState(()=>gender='F')))])]);

  Widget _buildYear() => TextField(decoration: InputDecoration(labelText: 'Enroll Year 2025', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number, controller: TextEditingController(text: year.toString()), onChanged: (v){ final y=int.tryParse(v); if(y!=null) setState(()=>year=y); });

  Widget _buildSessionSelector() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Study Session - D/E/W in 25D', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Row(children: StudySession.values.map((s) {
    final code = RegGenerator.sessionCode(s);
    final label = RegGenerator.sessionLabel(s);
    final selected = session==s;
    return Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text('$label ($code)'), selected: selected, onSelected: (_)=>setState(()=>session=s), selectedColor: const Color(0xFFF59E0B))));
  }).toList())]);

  Widget _buildNationality() => DropdownButtonFormField<String>(initialValue: nationality, decoration: InputDecoration(labelText: 'Nationality', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white), items: ['UG','KE','TZ','RW','SS','NG','GH'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>nationality=v!));

  Widget _buildSeq() => TextField(decoration: InputDecoration(labelText: 'Personal No e.g. 001', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number, controller: TextEditingController(text: seq.toString()), onChanged: (v){ final s=int.tryParse(v); if(s!=null) setState(()=>seq=s); });
}
