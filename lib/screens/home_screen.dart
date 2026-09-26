
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/student.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  List<Student> students = [];
  final db = DatabaseService();

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final s = await db.getStudents(); setState(()=>students=s); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('CampusCore'), backgroundColor: Colors.white, elevation: 0, actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.notifications_outlined))]),
      body: _body(),
      bottomNavigationBar: BottomNavigationBar(currentIndex: tab, onTap: (i)=>setState(()=>tab=i), type: BottomNavigationBarType.fixed, selectedItemColor: const Color(0xFF1E1B4B), items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Courses'),
        BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Attendance'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Fees'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ]),
    );
  }

  Widget _body() {
    switch(tab) {
      case 0: return _home();
      case 1: return const CoursesTab();
      case 2: return const AttendanceTab();
      case 3: return const FeesTab();
      case 4: return const ProfileTab();
      default: return _home();
    }
  }

  Widget _home() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1E1B4B), borderRadius: BorderRadius.circular(20)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good morning, ${students.isNotEmpty ? students.first.fullName : "Student"}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(students.isNotEmpty?students.first.regNo:'BACS/M/25D/UG/001', style: const TextStyle(color: Colors.white70, fontFamily: 'monospace'))])), Container(width: 44, height: 44, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white))])),
      const SizedBox(height: 16),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        _stat('Attendance','92%','up'), _stat('CGPA','4.2','up'), _stat('Tasks','3 pending','alert'), _stat('Balance','UGX 450k',''),
      ])),
      const SizedBox(height: 20),
      const Text("Today's Classes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _classTile('Data Structures','Room B12','09:00 - 10:30','Dr. Okello'),
      _classTile('Operating Systems','Online','11:00 - 12:30','Ms. Namatovu'),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFDE68A))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle), child: const Icon(Icons.timer_outlined, size: 16, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Coursework Deadline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text('BACS/M/25D group - Data Structures due tomorrow', style: TextStyle(fontSize: 12))]))])),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Recent Students (Your Format)', style: TextStyle(fontWeight: FontWeight.bold)), TextButton(onPressed: () => Navigator.pushNamed(context, '/admin-data'), child: const Text('Add New'))]),
      ...students.take(5).map((s) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [CircleAvatar(backgroundColor: const Color(0xFF1E1B4B), child: Text(s.gender, style: const TextStyle(color: Colors.white))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(s.regNo, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black54))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: s.session.toString().contains('day') ? const Color(0xFFFEF3C7) : const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(20)), child: Text(s.regNo.split('/')[2], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))]))),
    ]));
  }

  Widget _stat(String t, String v, String type) => Container(width: 120, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontSize: 11, color: Colors.black54)), const SizedBox(height: 6), Text(v, style: TextStyle(fontWeight: FontWeight.bold, color: type=='alert'?const Color(0xFFF59E0B):const Color(0xFF1E1B4B)))]));
  Widget _classTile(String course, String room, String time, String lect) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(width: 4, height: 40, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text('$room • $time', style: const TextStyle(fontSize: 11, color: Colors.black54)), Text(lect, style: const TextStyle(fontSize: 11, color: Colors.black38))]))]));
}

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      TextField(decoration: InputDecoration(hintText: 'Search course unit... e.g. Data Structures', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
      const SizedBox(height: 12),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['BACS','BIT','All','Year 2','25D','25E','25W'].map((e) => Padding(padding: const EdgeInsets.only(right: 8), child: Chip(label: Text(e), backgroundColor: Colors.white))).toList())),
      const SizedBox(height: 12),
      _courseCard('CSC2101','Data Structures','BACS - Year 2','Dr. Okello','3 assignments'),
      _courseCard('CSC2102','Operating Systems','BACS - Year 2','Ms. Namatovu','1 coursework'),
    ]);
  }
  static Widget _courseCard(String code, String name, String prog, String lect, String tasks) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)), child: Text(code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)))), Text(tasks, style: const TextStyle(fontSize: 11, color: Colors.black54))]), const SizedBox(height: 8), Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text('$prog • $lect', style: const TextStyle(fontSize: 12, color: Colors.black54)), const SizedBox(height: 12), const Row(children: [const Expanded(child: const LinearProgressIndicator(value: 0.7, backgroundColor: Color(0xFFE2E8F0), color: Color(0xFF2563EB))), const SizedBox(width: 8), const Text('70%', style: const TextStyle(fontSize: 11))])]));
}

class AttendanceTab extends StatelessWidget {
  const AttendanceTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle), child: const Icon(Icons.check, color: Color(0xFF059669), size: 32)), const SizedBox(height: 8), const Text('Present', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))), const Text('Marked by Dr. Okello • 09:02 AM', style: TextStyle(fontSize: 11, color: Colors.black54))]))]));
  }
}

class FeesTab extends StatelessWidget {
  const FeesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1E1B4B), borderRadius: BorderRadius.circular(20)),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fees Balance', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text('UGX 450,000', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: null,
          child: const Text('Make Payment - Mobile Money / Card', style: TextStyle(color: Colors.white)),
        ),
      ),
      const SizedBox(height: 16),
      const Text('Payment Methods: MTN MoMo, Airtel Money, Card, Bank', style: TextStyle(fontSize: 12, color: Colors.black54))
    ]);
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [ListTile(title: const Text('Language'), subtitle: const Text('English, Français, Español, Kiswahili'), trailing: const Icon(Icons.language), onTap: (){}), ListTile(title: const Text('Dark Mode'), trailing: Switch(value: false, onChanged: (_){})), const ListTile(title: const Text('Calendar Sync'), subtitle: const Text('Google / Outlook / Apple'), trailing: const Icon(Icons.sync)), ListTile(title: const Text('Data Structure Builder'), subtitle: const Text('Define your own tables & reg format'), trailing: const Icon(Icons.table_chart_outlined), onTap: () => Navigator.pushNamed(context, '/admin-data')), const ListTile(title: const Text('Support'), subtitle: const Text('support@campuscore.ac.ug'), trailing: const Icon(Icons.support_agent_outlined))]);
  }
}
