import '../models/auth_session.dart';
import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login/',
      body: {
        'identifier': identifier.trim(),
        'password': password,
      },
    );

    return AuthSession.fromJson(response);
  }

  Future<void> logout(String accessToken) async {
    await _apiClient.post(
      '/auth/logout/',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  void dispose() => _apiClient.dispose();
}
