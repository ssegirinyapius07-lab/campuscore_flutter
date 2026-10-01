import 'package:flutter/material.dart';

import '../models/student_dashboard.dart';

import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import '../services/student_academic_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final StudentAcademicService _academicService = StudentAcademicService();
  final AuthService _authService = AuthService();

  int _selectedIndex = 0;
  StudentDashboard? _dashboard;
  bool _loading = true;
  String? _error;

  late final AnimationController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _loadDashboard();
  }

  @override
  void dispose() {
    _academicService.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final session = await AuthStorage.load();

    if (session == null) {
      await AuthStorage.clear();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );

      return;
    }

    try {
      await _authService.logout(session);
    } catch (_) {
      // Continue with local logout even if the server request fails.
    }

    await AuthStorage.clear();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to log out of CampusCore?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final dashboard = await _academicService.getDashboard();

      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _loading = false;
      });

      _pageController
        ..reset()
        ..forward();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboard();
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = _dashboard;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: _buildAppBar(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _buildBody(dashboard),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final titles = <String>[
      'CampusCore',
      'Courses',
      'Attendance',
      'Results',
      'Profile',
    ];

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFFF5F7FB),
      surfaceTintColor: Colors.transparent,
      titleSpacing: 20,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Text(
          titles[_selectedIndex],
          key: ValueKey(_selectedIndex),
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        _AppBarIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => _showNotifications(context),
        ),
        const SizedBox(width: 8),
        _AppBarIconButton(
          icon: Icons.refresh_rounded,
          onTap: _refreshDashboard,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBody(StudentDashboard? dashboard) {
    if (_loading && dashboard == null) {
      return const _LoadingView(
        key: ValueKey('loading'),
      );
    }

    if (_error != null && dashboard == null) {
      return _ErrorState(
        key: const ValueKey('error'),
        message: _error!,
        onRetry: _loadDashboard,
      );
    }

    if (dashboard == null) {
      return _ErrorState(
        key: const ValueKey('empty'),
        message: 'Unable to load your academic information.',
        onRetry: _loadDashboard,
      );
    }

    switch (_selectedIndex) {
      case 1:
        return CoursesTab(
          key: const ValueKey('courses'),
          courses: dashboard.courses,
        );

      case 2:
        return AttendanceTab(
          key: const ValueKey('attendance'),
          attendance: dashboard.attendance,
        );

      case 3:
        return ResultsTab(
          key: const ValueKey('results'),
          assessments: dashboard.assessments,
        );

      case 4:
        return ProfileTab(
          key: const ValueKey('profile'),
          student: dashboard.student,
          onLogout: _confirmLogout,
        );

      default:
        return HomeDashboard(
          key: const ValueKey('home'),
          dashboard: dashboard,
          onRefresh: _refreshDashboard,
          onOpenTab: _selectTab,
        );
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavigationItem(
                icon: Icons.grid_view_rounded,
                label: 'Home',
                selected: _selectedIndex == 0,
                onTap: () => _selectTab(0),
              ),
              _NavigationItem(
                icon: Icons.menu_book_rounded,
                label: 'Courses',
                selected: _selectedIndex == 1,
                onTap: () => _selectTab(1),
              ),
              _NavigationItem(
                icon: Icons.bar_chart_rounded,
                label: 'Attendance',
                selected: _selectedIndex == 2,
                onTap: () => _selectTab(2),
              ),
              _NavigationItem(
                icon: Icons.assessment_outlined,
                label: 'Results',
                selected: _selectedIndex == 3,
                onTap: () => _selectTab(3),
              ),
              _NavigationItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: _selectedIndex == 4,
                onTap: () => _selectTab(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withValues(alpha: 0.42),
      transitionDuration: const Duration(milliseconds: 550),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _NotificationPanel();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final slide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved);

        final scale = Tween<double>(
          begin: 0.96,
          end: 1,
        ).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.dashboard,
    required this.onRefresh,
    required this.onOpenTab,
  });

  final StudentDashboard dashboard;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final student = dashboard.student;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeCard(
                    student: student,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle(
                    title: 'Academic overview',
                    subtitle: 'Your current academic activity',
                  ),
                  const SizedBox(height: 14),
                  _AcademicOverview(
                    dashboard: dashboard,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Quick access',
                    subtitle: 'Jump directly to your academic records',
                  ),
                  const SizedBox(height: 14),
                  _QuickAccessGrid(
                    onOpenTab: onOpenTab,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Current courses',
                    subtitle: 'Courses attached to your active enrollment',
                  ),
                  const SizedBox(height: 14),
                  if (dashboard.courses.isEmpty)
                    const _EmptyCard(
                      icon: Icons.menu_book_outlined,
                      title: 'No courses yet',
                      message:
                          'Your registered courses will appear here when they are available.',
                    )
                  else
                    ...dashboard.courses.take(4).toList().asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HomeCourseCard(
                              course: entry.value,
                              index: entry.key,
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Academic information',
                    subtitle: 'Your current student profile',
                  ),
                  const SizedBox(height: 14),
                  _AcademicInformation(
                    student: student,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.student,
  });

  final StudentSummary student;

  @override
  Widget build(BuildContext context) {
    final firstName = student.fullName.trim().isEmpty
        ? 'Student'
        : student.fullName.trim().split(' ').first;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF101828),
              Color(0xFF1D2939),
              Color(0xFF344054),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101828).withValues(alpha: 0.20),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -35,
              top: -45,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 25,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 35,
              bottom: -60,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 18,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Color(0xFF12B76A),
                            size: 8,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Welcome back, $firstName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your academic command center is ready.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _WelcomeDetail(
                      icon: Icons.badge_outlined,
                      value: student.admissionNumber.isEmpty
                          ? 'No admission number'
                          : student.admissionNumber,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _WelcomeDetail(
                        icon: Icons.school_outlined,
                        value: student.programName.isEmpty
                            ? 'Program unavailable'
                            : student.programName,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeDetail extends StatelessWidget {
  const _WelcomeDetail({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.75),
              size: 16,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicOverview extends StatelessWidget {
  const _AcademicOverview({
    required this.dashboard,
  });

  final StudentDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final attendance = dashboard.attendance;
    final attendancePercentage = attendance.percentage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final cardWidth = width >= 900
            ? (width - 36) / 4
            : width >= 560
                ? (width - 12) / 2
                : (width - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              width: cardWidth,
              icon: Icons.menu_book_rounded,
              title: 'Courses',
              value: '${dashboard.courses.length}',
              subtitle: 'Registered',
              accent: const Color(0xFF175CD3),
              index: 0,
            ),
            _MetricCard(
              width: cardWidth,
              icon: Icons.check_circle_outline_rounded,
              title: 'Attendance',
              value: '${attendancePercentage.round()}%',
              subtitle: '${attendance.present} present',
              accent: const Color(0xFF039855),
              index: 1,
            ),
            _MetricCard(
              width: cardWidth,
              icon: Icons.assignment_outlined,
              title: 'Results',
              value: '${dashboard.assessments.length}',
              subtitle: 'Assessments',
              accent: const Color(0xFF7F56D9),
              index: 2,
            ),
            _MetricCard(
              width: cardWidth,
              icon: Icons.calendar_month_outlined,
              title: 'Semester',
              value: _semesterLabel(dashboard),
              subtitle: 'Current period',
              accent: const Color(0xFFE04F16),
              index: 3,
            ),
          ],
        );
      },
    );
  }

  String _semesterLabel(StudentDashboard dashboard) {
    return '--';
  }
}

class _MetricCard extends StatefulWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.index,
  });

  final double width;
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final int index;

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: widget.width,
        padding: const EdgeInsets.all(18),
        transform: Matrix4.translationValues(
          0,
          _hovered ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: widget.accent.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.accent.withValues(
                alpha: _hovered ? 0.12 : 0.05,
              ),
              blurRadius: _hovered ? 24 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.icon,
                color: widget.accent,
                size: 21,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              widget.title,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({
    required this.onOpenTab,
  });

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.menu_book_rounded,
        'Courses',
        'View registered courses',
        1,
      ),
      (
        Icons.bar_chart_rounded,
        'Attendance',
        'Track attendance records',
        2,
      ),
      (
        Icons.assessment_outlined,
        'Results',
        'View assessment records',
        3,
      ),
      (
        Icons.person_outline_rounded,
        'Profile',
        'View student information',
        4,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 700
            ? (constraints.maxWidth - 24) / 3
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return _QuickAccessCard(
              width: cardWidth,
              icon: item.$1,
              title: item.$2,
              subtitle: item.$3,
              onTap: () => onOpenTab(item.$4),
            );
          }).toList(),
        );
      },
    );
  }
}

class _QuickAccessCard extends StatefulWidget {
  const _QuickAccessCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_QuickAccessCard> createState() => _QuickAccessCardState();
}

class _QuickAccessCardState extends State<_QuickAccessCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF175CD3).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.arrow_outward_rounded,
                  color: Color(0xFF175CD3),
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCourseCard extends StatelessWidget {
  const _HomeCourseCard({
    required this.course,
    required this.index,
  });

  final CourseSummary course;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF175CD3),
      const Color(0xFF7F56D9),
      const Color(0xFF039855),
      const Color(0xFFE04F16),
    ];

    final accent = colors[index % colors.length];

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 450 + (index * 100)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                course.code.isEmpty
                    ? '—'
                    : course.code.substring(
                        0,
                        course.code.length > 2 ? 2 : course.code.length,
                      ),
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.code.isEmpty ? 'Course' : course.code,
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.name.isEmpty
                        ? 'Course name unavailable'
                        : course.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${course.creditUnits} credit unit${course.creditUnits == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF98A2B3),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicInformation extends StatelessWidget {
  const _AcademicInformation({
    required this.student,
  });

  final StudentSummary student;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.person_outline_rounded,
            label: 'Student',
            value: student.fullName,
          ),
          _InformationRow(
            icon: Icons.badge_outlined,
            label: 'Admission number',
            value: student.admissionNumber,
          ),
          _InformationRow(
            icon: Icons.school_outlined,
            label: 'Program',
            value: student.programName,
          ),
          _InformationRow(
            icon: Icons.apartment_outlined,
            label: 'Faculty',
            value: student.facultyName,
          ),
          _InformationRow(
            icon: Icons.layers_outlined,
            label: 'Year of study',
            value: student.yearOfStudy.toString(),
          ),
          _InformationRow(
            icon: Icons.calendar_today_outlined,
            label: 'Session',
            value: student.session,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFF667085),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoursesTab extends StatelessWidget {
  const CoursesTab({
    super.key,
    required this.courses,
  });

  final List<CourseSummary> courses;

  @override
  Widget build(BuildContext context) {
    return _TabPage(
      title: 'Registered courses',
      subtitle: 'Courses currently linked to your academic record',
      child: courses.isEmpty
          ? const _EmptyCard(
              icon: Icons.menu_book_outlined,
              title: 'No courses yet',
              message:
                  'Your registered courses will appear here when they are available.',
            )
          : Column(
              children: courses.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HomeCourseCard(
                    course: entry.value,
                    index: entry.key,
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class AttendanceTab extends StatelessWidget {
  const AttendanceTab({
    super.key,
    required this.attendance,
  });

  final AttendanceSummary attendance;

  @override
  Widget build(BuildContext context) {
    final percentage = attendance.percentage;

    return _TabPage(
      title: 'Attendance',
      subtitle: 'Your attendance summary',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 145,
                  height: 145,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: (percentage / 100).clamp(0, 1),
                          strokeWidth: 12,
                          backgroundColor: const Color(0xFFEAECF0),
                          color: const Color(0xFF175CD3),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${percentage.round()}%',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Attendance',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _AttendanceRow(
                      label: 'Present',
                      value: attendance.present,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                    _AttendanceRow(
                      label: 'Absent',
                      value: attendance.absent,
                      icon: Icons.cancel_outlined,
                    ),
                    _AttendanceRow(
                      label: 'Late',
                      value: attendance.late,
                      icon: Icons.schedule_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsTab extends StatelessWidget {
  const ResultsTab({
    super.key,
    required this.assessments,
  });

  final List<AssessmentSummary> assessments;

  @override
  Widget build(BuildContext context) {
    return _TabPage(
      title: 'Results',
      subtitle: 'Your recorded assessments',
      child: assessments.isEmpty
          ? const _EmptyCard(
              icon: Icons.assessment_outlined,
              title: 'No results yet',
              message:
                  'Your assessment records will appear here when they are available.',
            )
          : Column(
              children: assessments.asMap().entries.map((entry) {
                final assessment = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF7F56D9).withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: Color(0xFF7F56D9),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assessment.name.isEmpty
                                  ? 'Assessment'
                                  : assessment.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Recorded result',
                              style: TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        assessment.score.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.student,
    required this.onLogout,
  });

  final StudentSummary student;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _TabPage(
      title: 'Student profile',
      subtitle: 'Information associated with your account',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFF101828),
                  child: Icon(
                    Icons.person_rounded,
                    size: 39,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  student.fullName.isEmpty ? 'Student' : student.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  student.admissionNumber,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _AcademicInformation(student: student),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF667085),
          ),
          const SizedBox(height: 7),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

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
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF175CD3).withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 220),
              child: Icon(
                icon,
                size: 21,
                color: selected
                    ? const Color(0xFF175CD3)
                    : const Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? const Color(0xFF175CD3)
                    : const Color(0xFF667085),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF344054),
          ),
        ),
      ),
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  const _NotificationPanel();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 650,
            maxHeight: 600,
          ),
          margin: EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: bottom + 8,
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF175CD3).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF175CD3),
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Your latest academic updates',
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF175CD3).withValues(alpha: 0.08),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF175CD3),
                        size: 29,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Important academic updates will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF667085),
              size: 27,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatefulWidget {
  const _LoadingView({
    super.key,
  });

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 6.283185,
            child: child,
          );
        },
        child: Container(
          width: 55,
          height: 55,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF175CD3),
                Color(0xFF7F56D9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF175CD3).withValues(alpha: 0.20),
                blurRadius: 25,
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF5F7FB),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFFF04438).withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFF04438).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Color(0xFFF04438),
                  size: 28,
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Unable to load data',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
