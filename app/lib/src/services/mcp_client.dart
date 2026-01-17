// MCP Client - fetches design specs and tool outputs from backend
import 'package:dio/dio.dart';

/// MCP Client for communicating with the backend MCP server
class MCPClient {
  final Dio _dio;
  final String baseUrl;

  MCPClient({String? baseUrl})
      : baseUrl = baseUrl ?? 'http://localhost:3845',
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Fetch design specification
  Future<Map<String, dynamic>> getDesignSpec() async {
    try {
      final response = await _dio.get('$baseUrl/design-spec');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Return stub data if server unavailable
      return _stubDesignSpec;
    }
  }

  /// Fetch UI example for a screen
  Future<Map<String, dynamic>> getScreenUI(String screen) async {
    try {
      final response = await _dio.get('$baseUrl/ui/$screen');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'error': 'Failed to load screen: $screen'};
    }
  }

  /// Execute an MCP tool
  Future<Map<String, dynamic>> executeTool(
      String toolId, Map<String, dynamic> inputs) async {
    try {
      final response = await _dio.post(
        '$baseUrl/tools/$toolId',
        data: inputs,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'error': 'Tool execution failed: $toolId'};
    }
  }

  /// Stub design spec for offline/dev use
  static const _stubDesignSpec = {
    'theme': {
      'background': '#0E0E0E',
      'surface': '#1A1A1A',
      'accent': '#FC4C02',
    },
    'components': ['WorkoutCard', 'BottomNav', 'AuthForm'],
    'screens': ['Home', 'Workouts', 'AI', 'Profile'],
  };
}
