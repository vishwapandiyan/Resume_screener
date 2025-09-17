import 'dart:convert';
import 'package:http/http.dart' as http;

class AnalyticsService {
  final String baseUrl;

  AnalyticsService({String? baseUrl})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'ATS_BASE_URL',
            defaultValue: 'https://1ac54b164b07.ngrok-free.app',
          );

  Uri _uri(String path) {
    final trimmedBase = baseUrl.trim();
    final baseNoSlash = trimmedBase.endsWith('/')
        ? trimmedBase.substring(0, trimmedBase.length - 1)
        : trimmedBase;
    final ensuredScheme =
        (baseNoSlash.startsWith('http://') ||
            baseNoSlash.startsWith('https://'))
        ? baseNoSlash
        : 'http://$baseNoSlash';
    final trimmedPath = path.trim();
    final pathWithSlash = trimmedPath.startsWith('/')
        ? trimmedPath
        : '/$trimmedPath';
    return Uri.parse('$ensuredScheme$pathWithSlash');
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Failed to decode JSON: $e');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Fetch real-time analytics data
  Future<Map<String, dynamic>> getRealTimeAnalytics({
    required String workspaceId,
    String? jobId,
  }) async {
    try {
      final response = await http.get(
        _uri('/analytics/real-time'),
        headers: {
          'Content-Type': 'application/json',
          'X-Workspace-ID': workspaceId,
          if (jobId != null) 'X-Job-ID': jobId,
        },
      );

      return _decodeJson(response);
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockAnalyticsData();
    }
  }

  /// Fetch skill trends data
  Future<List<Map<String, dynamic>>> getSkillTrends({
    required String workspaceId,
    String? jobId,
    int days = 30,
  }) async {
    try {
      final response = await http.get(
        _uri('/analytics/skill-trends'),
        headers: {
          'Content-Type': 'application/json',
          'X-Workspace-ID': workspaceId,
          if (jobId != null) 'X-Job-ID': jobId,
        },
      );

      final data = _decodeJson(response);
      return List<Map<String, dynamic>>.from(data['trends'] ?? []);
    } catch (e) {
      // Fallback to mock data
      return _getMockSkillTrends();
    }
  }

  /// Fetch candidate performance data
  Future<List<Map<String, dynamic>>> getCandidatePerformance({
    required String workspaceId,
    String? jobId,
  }) async {
    try {
      final response = await http.get(
        _uri('/analytics/candidate-performance'),
        headers: {
          'Content-Type': 'application/json',
          'X-Workspace-ID': workspaceId,
          if (jobId != null) 'X-Job-ID': jobId,
        },
      );

      final data = _decodeJson(response);
      return List<Map<String, dynamic>>.from(data['performance'] ?? []);
    } catch (e) {
      // Fallback to mock data
      return _getMockCandidatePerformance();
    }
  }

  /// Fetch job market insights
  Future<Map<String, dynamic>> getJobMarketInsights({
    required String jobTitle,
    String? location,
  }) async {
    try {
      final response = await http.post(
        _uri('/analytics/job-market'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'job_title': jobTitle,
          if (location != null) 'location': location,
        }),
      );

      return _decodeJson(response);
    } catch (e) {
      // Fallback to mock data
      return _getMockJobMarketData(jobTitle);
    }
  }

  /// Fetch performance trends
  Future<List<Map<String, dynamic>>> getPerformanceTrends({
    required String workspaceId,
    String? jobId,
    int days = 7,
  }) async {
    try {
      final response = await http.get(
        _uri('/analytics/performance-trends'),
        headers: {
          'Content-Type': 'application/json',
          'X-Workspace-ID': workspaceId,
          if (jobId != null) 'X-Job-ID': jobId,
        },
      );

      final data = _decodeJson(response);
      return List<Map<String, dynamic>>.from(data['trends'] ?? []);
    } catch (e) {
      // Fallback to mock data
      return _getMockPerformanceTrends();
    }
  }

  /// Export analytics report
  Future<Map<String, dynamic>> exportReport({
    required String workspaceId,
    String? jobId,
    String format = 'pdf',
  }) async {
    try {
      final response = await http.post(
        _uri('/analytics/export'),
        headers: {
          'Content-Type': 'application/json',
          'X-Workspace-ID': workspaceId,
        },
        body: jsonEncode({
          'format': format,
          if (jobId != null) 'job_id': jobId,
        }),
      );

      return _decodeJson(response);
    } catch (e) {
      throw Exception('Failed to export report: $e');
    }
  }

  /// Get dashboard summary
  Future<Map<String, dynamic>> getDashboardSummary({
    required String workspaceId,
  }) async {
    try {
      final response = await http.get(
        _uri('/analytics/dashboard-summary'),
        headers: {
          'Content-Type': 'application/json',
          'X-Workspace-ID': workspaceId,
        },
      );

      return _decodeJson(response);
    } catch (e) {
      // Fallback to mock data
      return _getMockDashboardSummary();
    }
  }

  // Mock data methods for fallback
  Map<String, dynamic> _getMockAnalyticsData() {
    return {
      'total_applications': 156,
      'high_matches': 23,
      'avg_response_time': '2.3h',
      'success_rate': 87.5,
      'trends': {
        'applications': '+12%',
        'matches': '+8%',
        'response_time': '-15%',
        'success_rate': '+5%',
      },
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _getMockSkillTrends() {
    return [
      {
        'skill': 'React',
        'count': 45,
        'percentage': 78,
        'trend': [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.78],
        'demand': 'High',
      },
      {
        'skill': 'Python',
        'count': 38,
        'percentage': 65,
        'trend': [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.65],
        'demand': 'High',
      },
      {
        'skill': 'AWS',
        'count': 32,
        'percentage': 55,
        'trend': [0.1, 0.15, 0.25, 0.35, 0.45, 0.5, 0.55],
        'demand': 'Medium',
      },
      {
        'skill': 'Docker',
        'count': 28,
        'percentage': 48,
        'trend': [0.05, 0.1, 0.2, 0.3, 0.35, 0.4, 0.48],
        'demand': 'Medium',
      },
      {
        'skill': 'Kubernetes',
        'count': 22,
        'percentage': 38,
        'trend': [0.02, 0.05, 0.1, 0.15, 0.25, 0.3, 0.38],
        'demand': 'Low',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockCandidatePerformance() {
    return List.generate(
      10,
      (index) => {
        'id': 'candidate_$index',
        'name': 'Candidate ${index + 1}',
        'score': 0.6 + (index * 0.03),
        'ats_score': 70 + (index * 2),
        'skills': ['React', 'Python', 'AWS'].take(2 + (index % 3)).toList(),
        'experience': '${2 + index} years',
        'email': 'candidate${index + 1}@email.com',
        'trend': List.generate(
          7,
          (i) => 0.3 + (i * 0.1) + (i % 2 == 0 ? 0.05 : -0.02),
        ),
        'last_updated': DateTime.now()
            .subtract(Duration(hours: index * 2))
            .toIso8601String(),
        'status': index < 3
            ? 'Shortlisted'
            : index < 7
            ? 'Under Review'
            : 'Pending',
      },
    );
  }

  Map<String, dynamic> _getMockJobMarketData(String jobTitle) {
    return {
      'demand': 'High',
      'competition': 'Medium',
      'avg_salary': '\$85,000',
      'growth_rate': '+12%',
      'skills_in_demand': ['React', 'Python', 'AWS', 'Docker', 'Kubernetes'],
      'location_insights': {'remote': 65, 'hybrid': 25, 'onsite': 10},
      'experience_levels': {'entry': 20, 'mid': 50, 'senior': 30},
    };
  }

  List<Map<String, dynamic>> _getMockPerformanceTrends() {
    return List.generate(
      7,
      (index) => {
        'date': DateTime.now()
            .subtract(Duration(days: 6 - index))
            .toIso8601String(),
        'applications': 20 + (index * 2),
        'matches': 5 + (index * 1),
        'response_time': 2.5 - (index * 0.1),
        'success_rate': 80 + (index * 2),
      },
    );
  }

  Map<String, dynamic> _getMockDashboardSummary() {
    return {
      'total_workspaces': 5,
      'active_jobs': 12,
      'total_candidates': 456,
      'avg_processing_time': '1.8h',
      'top_skills': ['React', 'Python', 'AWS', 'Docker', 'Kubernetes'],
      'recent_activity': [
        {
          'type': 'new_candidate',
          'message': 'New candidate applied for Senior Developer position',
          'timestamp': DateTime.now()
              .subtract(Duration(minutes: 15))
              .toIso8601String(),
        },
        {
          'type': 'interview_scheduled',
          'message': 'Interview scheduled for John Doe',
          'timestamp': DateTime.now()
              .subtract(Duration(hours: 2))
              .toIso8601String(),
        },
        {
          'type': 'job_published',
          'message': 'New job posting: Full Stack Developer',
          'timestamp': DateTime.now()
              .subtract(Duration(hours: 4))
              .toIso8601String(),
        },
      ],
    };
  }
}
