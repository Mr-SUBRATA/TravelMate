import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// API CONFIGURATION
// ─────────────────────────────────────────────────────────────────────────────
class ApiConfig {
  // TODO: Move to .env file before production
  // If you run the iOS/Android simulator **on this Mac**, localhost will hit the ML service.
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String mlBaseUrl = 'http://127.0.0.1:8000/api/ml';
  static const String apiPrefix = '/api';
}

// ─────────────────────────────────────────────────────────────────────────────
// API SERVICE — singleton with auto-injected Bearer token
// ─────────────────────────────────────────────────────────────────────────────
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // ── Main backend Dio instance ──
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  // ── ML backend Dio instance ──
  final Dio _mlDio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.mlBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  // ── Retrieve stored token ──
  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('clerk_token') ?? '';
  }

  Options _authOpts(String token) => Options(
        headers: {'Authorization': 'Bearer $token'},
      );

  // ────────────────────────────────────────────────────────────────────────────
  // AUTH
  // ────────────────────────────────────────────────────────────────────────────

  /// POST /api/user/sync
  /// Call after Clerk login/signup to create/update the user record.
  Future<ApiResult<Map<String, dynamic>>> syncUser({
    required String name,
    required String email,
  }) async {
    try {
      final token = await _token();
      final res = await _dio.post(
        '/api/user/sync',
        data: {'name': name, 'email': email},
        options: _authOpts(token),
      );
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // PREFERENCES
  // ────────────────────────────────────────────────────────────────────────────

  /// POST /api/preferences/save
  /// Called at the end of the onboarding flow with all collected data.
  Future<ApiResult<Map<String, dynamic>>> savePreferences({
    required List<String> quizAnswers,     // travel DNA selections
    required String travelPace,            // Budget / Balanced / Luxury
    required String crowdTolerance,        // derived from DNA
    required Map<String, double> budgetRange, // {min, max}
    required String groupSizePreference,
    required List<String> dealBreakers,
  }) async {
    try {
      final token = await _token();
      final res = await _dio.post(
        '/api/preferences/save',
        data: {
          'quizAnswers': quizAnswers,
          'travelPace': travelPace,
          'crowdTolerance': crowdTolerance,
          'budgetRange': budgetRange,
          'groupSizePreference': groupSizePreference,
          'dealBreakers': dealBreakers,
        },
        options: _authOpts(token),
      );
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// GET /api/preferences
  Future<ApiResult<Map<String, dynamic>>> getPreferences() async {
    try {
      final token = await _token();
      final res = await _dio.get(
        '/api/preferences',
        options: _authOpts(token),
      );
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // TRIPS
  // ────────────────────────────────────────────────────────────────────────────

  /// POST /api/trips/save
  Future<ApiResult<Map<String, dynamic>>> saveTrip({
    required String destinationCity,
    required String destinationCountry,
    required String startDate,
    required String endDate,
    required int groupSize,
    required double totalBudget,
  }) async {
    try {
      final token = await _token();
      final res = await _dio.post(
        '/api/trips/save',
        data: {
          'destinationCity': destinationCity,
          'destinationCountry': destinationCountry,
          'startDate': startDate,
          'endDate': endDate,
          'groupSize': groupSize,
          'totalBudget': totalBudget,
        },
        options: _authOpts(token),
      );
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// GET /api/trips/mytrips
  Future<ApiResult<List<dynamic>>> getMyTrips() async {
    try {
      final token = await _token();
      final res = await _dio.get(
        '/api/trips/mytrips',
        options: _authOpts(token),
      );
      if (res.statusCode == 200) {
        final data = res.data;
        final list = data is List
            ? data
            : (data['trips'] as List? ?? []);
        return ApiResult(success: true, data: list);
      }
      return ApiResult.error(
          res.data?['message'] ?? 'Failed to load trips');
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// DELETE /api/trips/:id
  Future<ApiResult<Map<String, dynamic>>> deleteTrip(
      String tripId) async {
    try {
      final token = await _token();
      final res = await _dio.delete(
        '/api/trips/$tripId',
        options: _authOpts(token),
      );
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // RECOMMENDATIONS
  // ────────────────────────────────────────────────────────────────────────────

  /// POST /api/recommendations/generate
  Future<ApiResult<Map<String, dynamic>>> generateRecommendations({
    required String destination,
    required String destinationCountry,
    required String startDate,
    required String endDate,
    required int groupSize,
    required double totalBudget,
    required List<String> quizAnswers,
    List<String> places = const [],
    int topK = 10,
  }) async {
    try {
      final token = await _token();
      final res = await _dio.post(
        '/api/recommendations/generate',
        data: {
          'destination': destination,
          'destinationCountry': destinationCountry,
          'startDate': startDate,
          'endDate': endDate,
          'groupSize': groupSize,
          'totalBudget': totalBudget,
          'quizAnswers': quizAnswers,
          'places': places,
          'top_k': topK,
        },
        options: _authOpts(token),
      );
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // FEEDBACK
  // ────────────────────────────────────────────────────────────────────────────

  /// POST /api/feedback/save
  Future<ApiResult<Map<String, dynamic>>> saveFeedback(
      Map<String, dynamic> feedback) async {
    try {
      final token = await _token();
      final res = await _dio.post(
        '/api/feedback/save',
        data: feedback,
        options: _authOpts(token),
      );
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// GET /api/feedback
  Future<ApiResult<List<dynamic>>> getFeedback() async {
    try {
      final token = await _token();
      final res = await _dio.get(
        '/api/feedback',
        options: _authOpts(token),
      );
      if (res.statusCode == 200) {
        final data = res.data;
        final list = data is List
            ? data
            : (data['feedback'] as List? ?? []);
        return ApiResult(success: true, data: list);
      }
      return ApiResult.error(
          res.data?['message'] ?? 'Failed to load feedback');
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ML ENDPOINTS
  // ────────────────────────────────────────────────────────────────────────────

  /// POST /api/ml/recommend
  Future<ApiResult<Map<String, dynamic>>> mlRecommend(
    Map<String, dynamic> body) async {
  try {
    final res = await _mlDio.post('/recommend', data: {
      'user_id': body['userId'] ?? 'anonymous',
      'destination': body['destination'],
      'top_k': body['topK'] ?? 5,
      'quiz_answers': {
        'art_interest': 3,
        'foodie_score': 3,
        'adventure_seeking': 3,
        'crowd_tolerance': 3,
        'budget_conscious': 3,
        'travel_pace': 'balanced',
        'interests': body['quizAnswers'] ?? [],
      },
    });
    return ApiResult.fromResponse(res);
  } on DioException catch (e) {
    return ApiResult.error(_dioMsg(e));
  }
}

  /// POST /api/ml/explain
  Future<ApiResult<Map<String, dynamic>>> mlExplain(
      Map<String, dynamic> body) async {
    try {
      final res = await _mlDio.post('/explain', data: body);
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// POST /api/ml/adapt-weather
  Future<ApiResult<Map<String, dynamic>>> mlAdaptWeather(
      Map<String, dynamic> body) async {
    try {
      final res =
          await _mlDio.post('/adapt-weather', data: body);
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// POST /api/ml/group-harmony
  Future<ApiResult<Map<String, dynamic>>> mlGroupHarmony(
      Map<String, dynamic> body) async {
    try {
      final res =
          await _mlDio.post('/group-harmony', data: body);
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// POST /api/ml/optimize-budget
  Future<ApiResult<Map<String, dynamic>>> mlOptimizeBudget(
      Map<String, dynamic> body) async {
    try {
      final res =
          await _mlDio.post('/optimize-budget', data: body);
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// POST /api/ml/route
  Future<ApiResult<Map<String, dynamic>>> mlRoute(
      Map<String, dynamic> body) async {
    try {
      final res = await _mlDio.post('/route', data: body);
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// POST /api/ml/assess-risk
  Future<ApiResult<Map<String, dynamic>>> mlAssessRisk(
      Map<String, dynamic> body) async {
    try {
      final res =
          await _mlDio.post('/assess-risk', data: body);
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// POST /api/ml/transport
  Future<ApiResult<Map<String, dynamic>>> mlTransport(
      Map<String, dynamic> body) async {
    try {
      final res =
          await _mlDio.post('/transport', data: body);
      return ApiResult.fromResponse(res);
    } on DioException catch (e) {
      return ApiResult.error(_dioMsg(e));
    }
  }

  /// GET /api/ml/health
  Future<bool> mlHealth() async {
    try {
      final res = await _mlDio.get('/health');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────────────
  String _dioMsg(DioException e) {
    if (e.response?.data != null) {
      final d = e.response!.data;
      if (d is Map) {
        return (d['message'] ?? d['error'] ?? e.message)
            .toString();
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check your network.';
      case DioExceptionType.connectionError:
        return 'Cannot reach server. Check your connection.';
      default:
        return e.message ?? 'Unknown error occurred.';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESULT WRAPPER
// ─────────────────────────────────────────────────────────────────────────────
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? error;

  const ApiResult({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResult.error(String message) =>
      ApiResult(success: false, error: message);

  factory ApiResult.fromResponse(Response res) {
    if (res.statusCode != null &&
        res.statusCode! >= 200 &&
        res.statusCode! < 300) {
      return ApiResult(
          success: true, data: res.data as T?);
    }
    final msg = (res.data is Map)
        ? (res.data['message'] ??
            res.data['error'] ??
            'Request failed (${res.statusCode})')
        : 'Request failed (${res.statusCode})';
    return ApiResult(success: false, error: msg.toString());
  }
}