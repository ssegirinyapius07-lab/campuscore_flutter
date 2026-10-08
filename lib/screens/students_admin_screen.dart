import 'package:flutter/material.dart';

import '../models/admin_models.dart';
import '../services/admin_service.dart';
import '../services/api_client.dart';

class StudentsAdminScreen extends StatefulWidget {
  const StudentsAdminScreen({
    super.key,
    required this.programs,
    this.onChanged,
  });

  final List<AdminProgram> programs;
  final Future<void> Function()? onChanged;

  @override
  State<StudentsAdminScreen> createState() => _StudentsAdminScreenState();
}

class _StudentsAdminScreenState extends State<StudentsAdminScreen> {
  final AdminService _service = AdminService();
  final TextEditingController _search = TextEditingController();

  List<AdminStudent> students = [];
  bool loading = true;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await _service.getStudents(search: _search.text);
      if (!mounted) return;
      setState(() {
        students = result;
        loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load students.';
        loading = false;
      });
    }
  }

  Future<void> _notifyParent() async {
    if (widget.onChanged != null) {
      await widget.onChanged!();
    }
  }

  Future<void> _addStudent() async {
    final created = await _studentDialog();
    if (created == true) {
      await _load();
      await _notifyParent();
    }
  }

  Future<void> _editStudent(AdminStudent student) async {
    final updated = await _studentDialog(student: student);
    if (updated == true) {
      await _load();
      await _notifyParent();
    }
  }

  Future<void> _deactivate(AdminStudent student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate student?'),
        content: Text(
          'This will deactivate ' +
              student.fullName +
              '\'s account. The student record will remain in the database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => busy = true);
    try {
      await _service.deactivateStudent(student.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student account deactivated.')),
      );
      await _load();
      await _notifyParent();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<bool?> _studentDialog({AdminStudent? student}) async {
    final editing = student != null;
    final activePrograms = widget.programs.where((p) => p.isActive).toList();

    final firstName = TextEditingController(text: student?.firstName ?? '');
    final lastName = TextEditingController(text: student?.lastName ?? '');
    final email = TextEditingController(text: student?.email ?? '');
    final phone = TextEditingController(text: student?.phone ?? '');
    final admission = TextEditingController(
      text: student?.admissionNumber ?? '',
    );
    final nationality = TextEditingController(
      text: student?.nationality ?? 'UG',
    );
    final enrollmentYear = TextEditingController(
      text: student?.enrollmentYear?.toString() ??
          DateTime.now().year.toString(),
    );
    final parentContact = TextEditingController(
      text: student?.parentContact ?? '',
    );
    final studyYear = TextEditingController(
      text: (student?.yearOfStudy ?? 1).toString(),
    );
    final password = TextEditingController();

    String gender = student?.gender.isNotEmpty == true ? student!.gender : 'M';
    String session =
        student?.session.isNotEmpty == true ? student!.session : 'day';
    int? programId = student?.program?.id;

    if (programId == null && activePrograms.isNotEmpty) {
      programId = activePrograms.first.id;
    }

    bool dialogBusy = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> save() async {
            final year = int.tryParse(enrollmentYear.text.trim());
            final yearOfStudy = int.tryParse(studyYear.text.trim());
            final pass = password.text.trim();

            if (firstName.text.trim().isEmpty ||
                lastName.text.trim().isEmpty ||
                email.text.trim().isEmpty ||
                admission.text.trim().isEmpty ||
                year == null ||
                yearOfStudy == null) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Complete the required fields.')),
              );
              return;
            }

            if (!editing && pass.length < 8) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text('Initial password must be at least 8 characters.'),
                ),
              );
              return;
            }

            if (activePrograms.isNotEmpty && programId == null) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Select a program.')),
              );
              return;
            }

            setDialogState(() => dialogBusy = true);

            try {
              if (editing) {
                await _service.updateStudent(
                  id: student!.id,
                  email: email.text.trim(),
                  firstName: firstName.text.trim(),
                  lastName: lastName.text.trim(),
                  phone: phone.text.trim(),
                  admissionNumber: admission.text.trim(),
                  programId: programId,
                  gender: gender,
                  nationality: nationality.text.trim(),
                  enrollmentYear: year,
                  session: session,
                  parentContact: parentContact.text.trim(),
                  yearOfStudy: yearOfStudy,
                  password: pass.isEmpty ? null : pass,
                );
              } else {
                await _service.createStudent(
                  email: email.text.trim(),
                  firstName: firstName.text.trim(),
                  lastName: lastName.text.trim(),
                  phone: phone.text.trim(),
                  admissionNumber: admission.text.trim(),
                  programId: programId,
                  gender: gender,
                  nationality: nationality.text.trim(),
                  enrollmentYear: year,
                  session: session,
                  parentContact: parentContact.text.trim(),
                  yearOfStudy: yearOfStudy,
                  password: pass,
                );
              }

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            } on ApiException catch (e) {
              setDialogState(() => dialogBusy = false);
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(e.message)),
                );
              }
            }
          }

          return AlertDialog(
            title: Text(editing ? 'Edit student' : 'Add student'),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(firstName, 'First name *'),
                    const SizedBox(height: 10),
                    _field(lastName, 'Last name *'),
                    const SizedBox(height: 10),
                    _field(
                      email,
                      'Email *',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      phone,
                      'Phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _field(admission, 'Admission number *'),
                    const SizedBox(height: 10),
                    if (activePrograms.isEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No active programs are available. Create an active program first.',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: programId,
                        decoration: const InputDecoration(
                          labelText: 'Program',
                        ),
                        items: activePrograms
                            .map(
                              (p) => DropdownMenuItem<int>(
                                value: p.id,
                                child: Text(p.code + ' - ' + p.name),
                              ),
                            )
                            .toList(),
                        onChanged: dialogBusy
                            ? null
                            : (value) => setDialogState(
                                  () => programId = value,
                                ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: gender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'M',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'F',
                                child: Text('Female'),
                              ),
                            ],
                            onChanged: dialogBusy
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setDialogState(() => gender = value);
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: session,
                            decoration: const InputDecoration(
                              labelText: 'Session',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'day',
                                child: Text('Day'),
                              ),
                              DropdownMenuItem(
                                value: 'evening',
                                child: Text('Evening'),
                              ),
                              DropdownMenuItem(
                                value: 'weekend',
                                child: Text('Weekend'),
                              ),
                            ],
                            onChanged: dialogBusy
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setDialogState(() => session = value);
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _field(nationality, 'Nationality'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            enrollmentYear,
                            'Enrollment year',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _field(
                      parentContact,
                      'Parent / guardian contact',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      studyYear,
                      'Year of study',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      password,
                      editing
                          ? 'New password (optional)'
                          : 'Initial password *',
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: dialogBusy
                    ? null
                    : () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: dialogBusy ? null : save,
                child: Text(editing ? 'Save changes' : 'Create student'),
              ),
            ],
          );
        },
      ),
    );

    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    admission.dispose();
    nationality.dispose();
    enrollmentYear.dispose();
    parentContact.dispose();
    studyYear.dispose();
    password.dispose();

    return result;
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = students.where((s) => s.isActive).length;
    final inactive = students.length - active;
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Students',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Manage student accounts and academic information from the live database.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: busy ? null : _addStudent,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add student'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _summary(active, inactive),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _load(),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search name, admission number, username or email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _search.clear();
                            _load();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (error != null)
            _errorCard()
          else if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (students.isEmpty)
            _emptyCard()
          else if (desktop)
            _table()
          else
            _mobileCards(),
        ],
      ),
    );
  }

  Widget _summary(int active, int inactive) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final columns = constraints.maxWidth >= 800 ? 3 : 1;
        const gap = 12.0;
        final width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        final cards = [
          _summaryCard(
            'Total students',
            students.length,
            Icons.people_outline,
          ),
          _summaryCard(
            'Active accounts',
            active,
            Icons.verified_user_outlined,
          ),
          _summaryCard(
            'Inactive accounts',
            inactive,
            Icons.person_off_outlined,
          ),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards.map((card) => SizedBox(width: width, child: card)).toList(),
        );
      },
    );
  }

  Widget _summaryCard(String label, int value, IconData icon) {
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
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _table() {
    return Card(
      elevation: 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Student')),
            DataColumn(label: Text('Admission')),
            DataColumn(label: Text('Program')),
            DataColumn(label: Text('Year')),
            DataColumn(label: Text('Session')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('')),
          ],
          rows: students.map((student) {
            final program = student.program == null
                ? 'Not assigned'
                : student.program!.code + ' - ' + student.program!.name;

            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 185,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          student.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(Text(student.admissionNumber)),
                DataCell(Text(program)),
                DataCell(Text(student.yearOfStudy.toString())),
                DataCell(Text(_sessionLabel(student.session))),
                DataCell(_status(student.isActive)),
                DataCell(_actions(student)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _mobileCards() {
    return Column(
      children: students.map((student) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        student.fullName.isEmpty
                            ? '?'
                            : student.fullName[0].toUpperCase(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            student.admissionNumber,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _status(student.isActive),
                  ],
                ),
                const Divider(height: 24),
                _detail('Program', student.program?.code ?? 'Not assigned'),
                _detail('Year', student.yearOfStudy.toString()),
                _detail('Session', _sessionLabel(student.session)),
                _detail('Email', student.email),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_actions(student)],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(AdminStudent student) {
    return PopupMenuButton<String>(
      tooltip: 'Student actions',
      onSelected: (value) {
        if (value == 'edit') {
          _editStudent(student);
        } else if (value == 'deactivate') {
          _deactivate(student);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit student'),
          ),
        ),
        if (student.isActive)
          const PopupMenuItem(
            value: 'deactivate',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.person_off_outlined),
              title: Text('Deactivate'),
            ),
          ),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  Widget _status(bool active) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(active ? 'Active' : 'Inactive'),
      backgroundColor:
          active ? const Color(0xFFE8F7EE) : const Color(0xFFF1F5F9),
      side: BorderSide.none,
    );
  }

  Widget _errorCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 10),
            Text(error!, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    final searching = _search.text.trim().isNotEmpty;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.school_outlined, size: 42),
            const SizedBox(height: 12),
            Text(
              searching ? 'No students match your search.' : 'No students yet.',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              searching
                  ? 'Try another name, admission number or email.'
                  : 'Create the first student from this screen.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            if (!searching) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _addStudent,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add student'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _sessionLabel(String value) {
    switch (value) {
      case 'day':
        return 'Day';
      case 'evening':
        return 'Evening';
      case 'weekend':
        return 'Weekend';
      default:
        return value.isEmpty ? 'Not set' : value;
    }
  }
}
