import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';
import '../services/api_client.dart';
import '../services/auth_storage.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});
  @override State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final AdminService _service = AdminService();
  int section = 0; bool loading = true; String? error; String displayName = 'Super Admin';
  AdminDashboardStats? stats; List<AdminFaculty> faculties = [];
  List<AdminProgramLevel> levels = []; List<AdminProgram> programs = [];

  final items = const <_AdminItem>[
    _AdminItem('Overview', Icons.space_dashboard_outlined),
    _AdminItem('Academic Structure', Icons.account_tree_outlined),
    _AdminItem('Students', Icons.school_outlined),
    _AdminItem('Staff & Roles', Icons.badge_outlined),
    _AdminItem('Curriculum', Icons.menu_book_outlined),
    _AdminItem('Academic Calendar', Icons.calendar_month_outlined),
    _AdminItem('System Settings', Icons.settings_outlined),
  ];

  @override void initState() { super.initState(); load(); }
  @override void dispose() { _service.dispose(); super.dispose(); }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try {
      final session = await AuthStorage.load();
      final result = await Future.wait([
        _service.getDashboard(), _service.getFaculties(),
        _service.getProgramLevels(), _service.getPrograms(),
      ]);
      if (!mounted) return;
      setState(() {
        displayName = session?.displayName.isNotEmpty == true ? session!.displayName : 'Super Admin';
        stats = result[0] as AdminDashboardStats; faculties = result[1] as List<AdminFaculty>;
        levels = result[2] as List<AdminProgramLevel>; programs = result[3] as List<AdminProgram>; loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return; setState(() { error = e.message; loading = false; });
    } catch (_) {
      if (!mounted) return; setState(() { error = 'Could not load the Super Admin console.'; loading = false; });
    }
  }

  Future<void> logout() async {
    await _service.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void select(int index) {
    setState(() => section = index);
    if (MediaQuery.sizeOf(context).width < 900) Navigator.of(context).maybePop();
  }

  @override Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: desktop ? null : Drawer(child: navigation()),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: Text(items[section].title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
        actions: [
          IconButton(onPressed: loading ? null : load, tooltip: 'Refresh', icon: const Icon(Icons.refresh_rounded)),
          PopupMenuButton<String>(
            onSelected: (value) { if (value == 'logout') logout(); },
            itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Log out'))],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: desktop ? Row(children: [SizedBox(width: 270, child: navigation()), const VerticalDivider(width: 1), Expanded(child: content())]) : content(),
    );
  }

  Widget navigation() => ColoredBox(
    color: const Color(0xFF0F172A),
    child: SafeArea(
      child: Column(children: [
        const Padding(padding: EdgeInsets.fromLTRB(22, 26, 18, 22), child: Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CAMPUSCORE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          SizedBox(height: 5), Text('SUPER ADMIN CONSOLE', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ]))),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: items.length,
          itemBuilder: (_, i) { final selected = section == i; final item = items[i]; return Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              tileColor: selected ? const Color(0xFF1E293B) : Colors.transparent,
              leading: Icon(item.icon, color: selected ? Colors.white : const Color(0xFF94A3B8)),
              title: Text(item.title, style: TextStyle(color: selected ? Colors.white : const Color(0xFFCBD5E1), fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
              trailing: i > 1 ? const Text('SOON', style: TextStyle(color: Color(0xFF64748B), fontSize: 8, fontWeight: FontWeight.w800)) : null,
              onTap: () => select(i),
            ),
          ); },
        )),
        Padding(padding: const EdgeInsets.fromLTRB(18, 12, 18, 20), child: Row(children: [
          const CircleAvatar(radius: 18, backgroundColor: Color(0xFF1E293B), child: Icon(Icons.admin_panel_settings_outlined, color: Colors.white)),
          const SizedBox(width: 10), Expanded(child: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
        ])),
      ]),
    ),
  );

  Widget content() {
    if (loading && stats == null) return const Center(child: CircularProgressIndicator());
    if (error != null && stats == null) return errorView();
    if (section == 1) return academicStructure();
    if (section == 0) return overview();
    return modulePage(items[section].title, items[section].icon, stats!);
  }

  Widget overview() {
    final s = stats!;
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(padding: const EdgeInsets.all(22), children: [
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)), child: Row(children: [
          const CircleAvatar(radius: 28, backgroundColor: Color(0xFF1E293B), child: Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 28)),
          const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('SUPER ADMIN CONTROL CENTER', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(height: 6), Text('Welcome, $displayName', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6), const Text('Manage the institution from one place using live CampusCore data.', style: TextStyle(color: Color(0xFFCBD5E1))),
          ])),
        ])),
        const SizedBox(height: 22), const _Heading('System overview', 'Live figures from the CampusCore database.'), const SizedBox(height: 12),
        LayoutBuilder(builder: (_, c) { final cols = c.maxWidth >= 1100 ? 4 : c.maxWidth >= 700 ? 3 : 2; final w = (c.maxWidth - ((cols - 1) * 12)) / cols; final m = <_Metric>[
          _Metric('Total users', s.totalUsers, Icons.people_outline), _Metric('Students', s.students, Icons.school_outlined),
          _Metric('Lecturers', s.lecturers, Icons.co_present_outlined), _Metric('Programs', s.programs, Icons.account_tree_outlined),
          _Metric('Faculties', s.faculties, Icons.domain_outlined), _Metric('Course units', s.courseUnits, Icons.menu_book_outlined),
          _Metric('Academic years', s.academicYears, Icons.calendar_month_outlined), _Metric('Semesters', s.semesters, Icons.event_note_outlined),
        ]; return Wrap(spacing: 12, runSpacing: 12, children: m.map((x) => SizedBox(width: w, child: metricCard(x))).toList()); }),
        const SizedBox(height: 22), Row(children: [
          Expanded(child: actionCard(Icons.domain_add_outlined, 'Add faculty', 'Create a faculty in the live database.', showCreateFaculty)),
          const SizedBox(width: 14),
          Expanded(child: actionCard(Icons.add_business_outlined, 'Add program', 'Register a program under a faculty and level.', showCreateProgram)),
        ]),
          const SizedBox(height: 22),
          listCard(
            'Programs in the database',
            programs.isEmpty
                ? const Text('No programs yet.')
                : Column(
                    children: programs.take(6).map((program) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          ${program.code} — ${program.name},
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          ${program.faculty.code} • ${program.level.code} • ${program.durationYears} years,
                        ),
                      );
                    }).toList(),
                  ),
          ),
      ]),
    );
  }

  Widget academicStructure() => ListView(padding: const EdgeInsets.all(22), children: [
    Row(children: [const Expanded(child: _Heading('Academic structure', 'Faculties and programs stored in Django.')), FilledButton.icon(onPressed: showCreateProgram, icon: const Icon(Icons.add), label: const Text('New program'))]),
    const SizedBox(height: 18),
    LayoutBuilder(builder: (_, c) { final stacked = c.maxWidth < 780; final a = listCard('Faculties • ${faculties.length}', faculties.isEmpty ? const Text('No faculties have been created yet.') : Column(children: faculties.map((f) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(radius: 18, backgroundColor: const Color(0xFFEFF6FF), child: Text(f.code.length >= 2 ? f.code.substring(0, 2) : f.code)), title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(f.code))).toList()), trailing: IconButton(onPressed: showCreateFaculty, icon: const Icon(Icons.add))); final b = listCard('Programs • ${programs.length}', programs.isEmpty ? const Text('No programs have been created yet.') : Column(children: programs.map((p) => ListTile(contentPadding: EdgeInsets.zero, title: Text(${p.code} — ${p.name}, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(${p.faculty.code} • ${p.level.code} • ${p.durationYears} years))).toList()), trailing: IconButton(onPressed: showCreateProgram, icon: const Icon(Icons.add))); return stacked ? Column(children: [a, const SizedBox(height: 16), b]) : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: a), const SizedBox(width: 16), Expanded(child: b)]); }),
  ]);

  Widget modulePage(
    String title,
    IconData icon,
    AdminDashboardStats s,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Icon(icon, size: 34),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This module is next in the live backend build. It will be connected directly to CampusCore database records rather than local phone storage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Current system users: ${s.totalUsers}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget metricCard(_Metric metric) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(metric.icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.value.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionCard(
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget listCard(
    String title,
    Widget child, {
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 42),
                const SizedBox(height: 14),
                Text(error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: load,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showCreateFaculty() async {
    final code = TextEditingController();
    final name = TextEditingController();
    final description = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create faculty'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: code,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Faculty code'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Faculty name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (code.text.trim().isEmpty || name.text.trim().isEmpty) {
                  return;
                }

                try {
                  await _service.createFaculty(
                    code: code.text.trim().toUpperCase(),
                    name: name.text.trim(),
                    description: description.text.trim(),
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } on ApiException catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(e.message)),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    code.dispose();
    name.dispose();
    description.dispose();

    if (created == true) {
      await load();
    }
  }

  Future<void> showCreateProgram() async {
    final activeLevels = levels.where((level) => level.isActive).toList();

    if (faculties.isEmpty || activeLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Create a faculty and an active program level first.',
          ),
        ),
      );
      return;
    }

    final code = TextEditingController();
    final name = TextEditingController();
    final duration = TextEditingController(text: '4');
    final description = TextEditingController();

    int facultyId = faculties.first.id;
    int levelId = activeLevels.first.id;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              title: const Text('Create academic program'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: code,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(labelText: 'Program code'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Program name'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: facultyId,
                        decoration: const InputDecoration(labelText: 'Faculty'),
                        items: faculties.map((faculty) {
                          return DropdownMenuItem<int>(
                            value: faculty.id,
                            child: Text(
                              ${faculty.code} — ${faculty.name},
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setStateDialog(() => facultyId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: levelId,
                        decoration: const InputDecoration(labelText: 'Program level'),
                        items: activeLevels.map((level) {
                          return DropdownMenuItem<int>(
                            value: level.id,
                            child: Text(
                              ${level.code} — ${level.name},
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setStateDialog(() => levelId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: duration,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration in years',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: description,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final years = int.tryParse(duration.text.trim());

                    if (code.text.trim().isEmpty ||
                        name.text.trim().isEmpty ||
                        years == null ||
                        years < 1) {
                      return;
                    }

                    try {
                      await _service.createProgram(
                        code: code.text.trim().toUpperCase(),
                        name: name.text.trim(),
                        durationYears: years,
                        facultyId: facultyId,
                        levelId: levelId,
                        description: description.text.trim(),
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } on ApiException catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    code.dispose();
    name.dispose();
    duration.dispose();
    description.dispose();

    if (created == true) {
      await load();
    }
  }
}

class _AdminItem {
  const _AdminItem(this.title, this.icon);

  final String title;
  final IconData icon;
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final int value;
  final IconData icon;
}

class _Heading extends StatelessWidget {
  const _Heading(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
