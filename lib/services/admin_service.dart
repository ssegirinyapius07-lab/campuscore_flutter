import '../models/admin_models.dart';
import '../models/auth_session.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class AdminService {
  AdminService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthSession> _requireSession() async {
    final session = await AuthStorage.load();

    if (session == null ||
        session.accessToken.isEmpty ||
        session.refreshToken.isEmpty) {
      throw const ApiException(
        'Your session has expired. Please sign in again.',
        statusCode: 401,
      );
    }

    return session;
  }

  Future<AuthSession> _refreshSession(AuthSession session) async {
    final response = await _apiClient.post(
      '/auth/refresh/',
      body: {'refresh': session.refreshToken},
    );

    final refreshed = AuthSession(
      accessToken: response['access'] as String? ?? '',
      refreshToken:
          response['refresh'] as String? ?? session.refreshToken,
      userId: response['user_id']?.toString() ?? session.userId,
      role: response['role'] as String? ?? session.role,
      displayName:
          response['display_name'] as String? ?? session.displayName,
    );

    if (refreshed.accessToken.isEmpty) {
      throw const ApiException(
        'Your session could not be renewed. Please sign in again.',
        statusCode: 401,
      );
    }

    await AuthStorage.save(refreshed);
    return refreshed;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    var session = await _requireSession();

    try {
      return await _apiClient.get(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
    } on ApiException catch (e) {
      if (e.statusCode != 401) rethrow;

      session = await _refreshSession(session);

      return _apiClient.get(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
    }
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    var session = await _requireSession();

    try {
      return await _apiClient.post(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: body,
      );
    } on ApiException catch (e) {
      if (e.statusCode != 401) rethrow;

      session = await _refreshSession(session);

      return _apiClient.post(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: body,
      );
    }
  }

  Future<Map<String, dynamic>> _put(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    var session = await _requireSession();

    try {
      return await _apiClient.put(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: body,
      );
    } on ApiException catch (e) {
      if (e.statusCode != 401) rethrow;
      session = await _refreshSession(session);
      return _apiClient.put(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: body,
      );
    }
  }

  Future<Map<String, dynamic>> _patch(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    var session = await _requireSession();

    try {
      return await _apiClient.patch(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: body,
      );
    } on ApiException catch (e) {
      if (e.statusCode != 401) rethrow;
      session = await _refreshSession(session);
      return _apiClient.patch(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: body,
      );
    }
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    var session = await _requireSession();

    try {
      return await _apiClient.delete(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
    } on ApiException catch (e) {
      if (e.statusCode != 401) rethrow;
      session = await _refreshSession(session);
      return _apiClient.delete(
        path,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
    }
  }

  Future<List<AdminStudent>> getStudents({String search = ''}) async {
    final query = search.trim();
    final path = query.isEmpty
        ? '/admin/students/'
        : '/admin/students/?search=${Uri.encodeQueryComponent(query)}';

    final response = await _get(path);
    final items = response['items'];

    if (items is! List) {
      throw const ApiException('Invalid students response.');
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminStudent.fromJson)
        .toList();
  }

  Future<AdminStudent> createStudent({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String admissionNumber,
    int? programId,
    required String gender,
    required String nationality,
    int? enrollmentYear,
    required String session,
    required String parentContact,
    required int yearOfStudy,
    required String password,
  }) async {
    final response = await _post(
      '/admin/students/',
      body: {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'admission_number': admissionNumber,
        if (programId != null) 'program_id': programId,
        'gender': gender,
        'nationality': nationality,
        if (enrollmentYear != null) 'enrollment_year': enrollmentYear,
        'session': session,
        'parent_contact': parentContact,
        'year_of_study': yearOfStudy,
        'password': password,
      },
    );

    return AdminStudent.fromJson(response);
  }

  Future<AdminStudent> updateStudent({
    required int id,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String admissionNumber,
    int? programId,
    required String gender,
    required String nationality,
    int? enrollmentYear,
    required String session,
    required String parentContact,
    required int yearOfStudy,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'admission_number': admissionNumber,
      'program_id': programId,
      'gender': gender,
      'nationality': nationality,
      'enrollment_year': enrollmentYear,
      'session': session,
      'parent_contact': parentContact,
      'year_of_study': yearOfStudy,
    };

    if (password != null && password.trim().isNotEmpty) {
      body['password'] = password.trim();
    }

    return AdminStudent.fromJson(
      await _patch('/admin/students/$id/', body: body),
    );
  }

  Future<void> deactivateStudent(int id) async {
    await _delete('/admin/students/$id/');
  }

  Future<AdminDashboardStats> getDashboard() async =>
      AdminDashboardStats.fromJson(await _get('/admin/dashboard/'));

  Future<List<AdminFaculty>> getFaculties() async {
    final response = await _get('/admin/faculties/');
    final items = response['items'];

    if (items is! List) {
      throw const ApiException('Invalid faculties response.');
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminFaculty.fromJson)
        .toList();
  }

  Future<List<AdminProgramLevel>> getProgramLevels() async {
    final response = await _get('/admin/program-levels/');
    final items = response['items'];

    if (items is! List) {
      throw const ApiException('Invalid program levels response.');
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminProgramLevel.fromJson)
        .toList();
  }

  Future<List<AdminProgram>> getPrograms() async {
    final response = await _get('/admin/programs/');
    final items = response['items'];

    if (items is! List) {
      throw const ApiException('Invalid programs response.');
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminProgram.fromJson)
        .toList();
  }

  Future<AdminFaculty> createFaculty({
    required String code,
    required String name,
    String description = '',
  }) async {
    final response = await _post(
      '/admin/faculties/',
      body: {
        'code': code,
        'name': name,
        'description': description,
      },
    );

    return AdminFaculty.fromJson(response);
  }

  Future<AdminProgram> createProgram({
    required String code,
    required String name,
    required int durationYears,
    required int facultyId,
    required int levelId,
    String description = '',
  }) async {
    final response = await _post(
      '/admin/programs/',
      body: {
        'code': code,
        'name': name,
        'duration_years': durationYears,
        'description': description,
        'is_active': true,
        'faculty_id': facultyId,
        'level_id': levelId,
      },
    );

    return AdminProgram.fromJson(response);
  }

  Future<void> logout() async {
    final session = await AuthStorage.load();

    if (session != null) {
      try {
        await _apiClient.post(
          '/auth/logout/',
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
          },
          body: {'refresh': session.refreshToken},
        );
      } catch (_) {}
    }

    await AuthStorage.clear();
  }

  void dispose() => _apiClient.dispose();
}
