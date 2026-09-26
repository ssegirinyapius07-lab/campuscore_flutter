import 'package:flutter/material.dart';

import '../models/student_dashboard.dart';
import '../services/api_client.dart';
import '../services/student_academic_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  late final StudentAcademicService _academicService;
  StudentDashboard? dashboard;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _academicService = StudentAcademicService();
    _loadDashboard();
  }

  @override
  void dispose() {
    _academicService.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() { loading = true; error = null; });
    try {
      final result = await _academicService.getDashboard();
      if (!mounted) return;
      setState(() { dashboard = result; loading = false; });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { error = e.message; loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load your academic information. Check your connection and try again.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusCore'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loading ? null : _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _body(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) => setState(() => tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Courses'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Fees'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _body() {
    if (loading && dashboard == null) return const Center(child: CircularProgressIndicator());
    if (error != null && dashboard == null) return _ErrorState(message: error!, onRetry: _loadDashboard);

    final data = dashboard!;
    switch (tab) {
      case 1: return CoursesTab(courses: data.courses);
      case 2: return AttendanceTab(attendance: data.attendance);
      case 3: return const FeesTab();
      case 4: return ProfileTab(student: data.student);
      default: return _HomeTab(dashboard: data, refreshing: loading, onRefresh: _loadDashboard);
    }
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.dashboard, required this.refreshing, required this.onRefresh});
  final StudentDashboard dashboard;
  final bool refreshing;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final student = dashboard.student;
    final attendance = dashboard.attendance;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
            children: [
              _StudentHeader(student: student),
              const SizedBox(height: 16),
              _StatsGrid(attendance: attendance, courseCount: dashboard.courses.length, assessmentCount: dashboard.assessments.length),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Text('My Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  if (refreshing) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              const SizedBox(height: 10),
              if (dashboard.courses.isEmpty)
                const _EmptyCard(message: 'No active courses are assigned to your program yet.')
              else
                ...dashboard.courses.take(5).map(_CourseTile.new),
              const SizedBox(height: 24),
              _AcademicSummary(attendance: attendance, assessments: dashboard.assessments),
            ],
          );
        },
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.student});
  final StudentSummary student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E1B4B), borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ' + (student.fullName.isEmpty ? 'Student' : student.fullName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (student.admissionNumber.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(student.admissionNumber, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 12)),
                ],
                if (student.programName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(student.programName, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(radius: 22, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.attendance, required this.courseCount, required this.assessmentCount});
  final AttendanceSummary attendance;
  final int courseCount;
  final int assessmentCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        final spacing = 10.0;
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(width: width, child: _StatCard(label: 'Attendance', value: attendance.percentage.toStringAsFixed(0) + '%')),
            SizedBox(width: width, child: _StatCard(label: 'Courses', value: courseCount.toString())),
            SizedBox(width: width, child: _StatCard(label: 'Present', value: attendance.present.toString())),
            SizedBox(width: width, child: _StatCard(label: 'Assessments', value: assessmentCount.toString())),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile(this.course);
  final CourseSummary course;

  @override
  Widget build(BuildContext context) {
    final units = course.creditUnits == 1 ? 'credit unit' : 'credit units';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  course.code + ' • ' + course.creditUnits.toString() + ' ' + units,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademicSummary extends StatelessWidget {
  const _AcademicSummary({required this.attendance, required this.assessments});
  final AttendanceSummary attendance;
  final List<AssessmentSummary> assessments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Academic summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Attendance: ' + attendance.present.toString() + ' present, ' + attendance.absent.toString() + ' absent, ' + attendance.late.toString() + ' late.'),
          const SizedBox(height: 8),
          Text('Recorded assessments: ' + assessments.length.toString() + '.'),
        ],
      ),
    );
  }
}

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key, required this.courses});
  final List<CourseSummary> courses;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('My Courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (courses.isEmpty) const _EmptyCard(message: 'No active courses are available yet.')
        else ...courses.map(_CourseTile.new),
      ],
    );
  }
}

class AttendanceTab extends StatelessWidget {
  const AttendanceTab({super.key, required this.attendance});
  final AttendanceSummary attendance;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Attendance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _StatsGrid(attendance: attendance, courseCount: 0, assessmentCount: 0),
        const SizedBox(height: 16),
        _EmptyCard(
          message: attendance.total == 0
              ? 'No attendance records have been recorded yet.'
              : 'You have ' + attendance.present.toString() + ' present, ' + attendance.absent.toString() + ' absent and ' + attendance.late.toString() + ' late records.',
        ),
      ],
    );
  }
}

class FeesTab extends StatelessWidget {
  const FeesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Fees information will appear here when the fees API is connected.', textAlign: TextAlign.center),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.student});
  final StudentSummary student;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('My Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListTile(title: const Text('Name'), subtitle: Text(student.fullName)),
        ListTile(title: const Text('Admission number'), subtitle: Text(student.admissionNumber)),
        ListTile(title: const Text('Program'), subtitle: Text(student.programName)),
        ListTile(title: const Text('Faculty'), subtitle: Text(student.facultyName)),
        ListTile(title: const Text('Year of study'), subtitle: Text(student.yearOfStudy.toString())),
        ListTile(title: const Text('Session'), subtitle: Text(student.session)),
        ListTile(title: const Text('Email'), subtitle: Text(student.email)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
