import '../models/student_dashboard.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class StudentAcademicService {
  StudentAcademicService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;

  Future<StudentDashboard> getDashboard() async {
    final session = await AuthStorage.load();
    if (session == null || session.accessToken.isEmpty) {
      throw const ApiException('Your session has expired. Please sign in again.');
    }
    final response = await _apiClient.get('/student/dashboard/', headers: {'Authorization': 'Bearer ' + session.accessToken});
    return StudentDashboard.fromJson(response);
  }

  void dispose() => _apiClient.dispose();
}