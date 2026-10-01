import '../models/admin_models.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class AdminService {
  AdminService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;

  Future<Map<String, String>> _headers() async {
    final session = await AuthStorage.load();
    if (session == null || session.accessToken.isEmpty) {
      throw const ApiException('Your session has expired. Please sign in again.');
    }
    return {'Authorization': 'Bearer ' + session.accessToken};
  }

  Future<AdminDashboardStats> getDashboard() async => AdminDashboardStats.fromJson(
        await _apiClient.get('/admin/dashboard/', headers: await _headers()),
      );

  Future<List<AdminFaculty>> getFaculties() async {
    final response = await _apiClient.get('/admin/faculties/', headers: await _headers());
    final items = response['items'];
    if (items is! List) throw const ApiException('Invalid faculties response.');
    return items.whereType<Map<String, dynamic>>().map(AdminFaculty.fromJson).toList();
  }

  Future<List<AdminProgramLevel>> getProgramLevels() async {
    final response = await _apiClient.get('/admin/program-levels/', headers: await _headers());
    final items = response['items'];
    if (items is! List) throw const ApiException('Invalid program levels response.');
    return items.whereType<Map<String, dynamic>>().map(AdminProgramLevel.fromJson).toList();
  }

  Future<List<AdminProgram>> getPrograms() async {
    final response = await _apiClient.get('/admin/programs/', headers: await _headers());
    final items = response['items'];
    if (items is! List) throw const ApiException('Invalid programs response.');
    return items.whereType<Map<String, dynamic>>().map(AdminProgram.fromJson).toList();
  }

  Future<AdminFaculty> createFaculty({required String code, required String name, String description = ''}) async {
    final response = await _apiClient.post('/admin/faculties/', headers: await _headers(), body: {
      'code': code, 'name': name, 'description': description,
    });
    return AdminFaculty.fromJson(response);
  }

  Future<AdminProgram> createProgram({required String code, required String name, required int durationYears, required int facultyId, required int levelId, String description = ''}) async {
    final response = await _apiClient.post('/admin/programs/', headers: await _headers(), body: {
      'code': code, 'name': name, 'duration_years': durationYears, 'description': description,
      'is_active': true, 'faculty_id': facultyId, 'level_id': levelId,
    });
    return AdminProgram.fromJson(response);
  }

  Future<void> logout() async {
    final session = await AuthStorage.load();
    if (session != null) {
      try {
        await _apiClient.post('/auth/logout/', headers: {'Authorization': 'Bearer ' + session.accessToken}, body: {'refresh': session.refreshToken});
      } catch (_) {}
    }
    await AuthStorage.clear();
  }

  void dispose() => _apiClient.dispose();
}