import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import '../models/ats_workflow_models.dart';

class AtsService {
  AtsService({String? baseUrl})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'ATS_BASE_URL',
            defaultValue: 'https://0da70a85088d.ngrok-free.app',
          );

  final String baseUrl;

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

  Future<Map<String, dynamic>> health() async {
    final response = await http.get(_uri('/health'));
    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> processResumes({
    required List<PlatformFile> files,
    int threshold = 60,
  }) async {
    final uri = _uri('/process-resumes');
    final request = http.MultipartRequest('POST', uri);
    request.fields['threshold'] = threshold.toString();

    for (final file in files) {
      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            file.bytes as Uint8List,
            filename: file.name,
            contentType: _contentTypeFor(file.extension),
          ),
        );
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path!,
            filename: file.name,
            contentType: _contentTypeFor(file.extension),
          ),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> semanticRanking({
    required String jobDescription,
    required List<ProcessedResume> resumes,
  }) async {
    // Convert ProcessedResume objects to Map for API call
    final resumeMaps = resumes.map((resume) => resume.toJson()).toList();

    final response = await http.post(
      _uri('/semantic-ranking'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'job_description': jobDescription,
        'resumes': resumeMaps,
      }),
    );
    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> filterResumes({
    required List<RankedResume> resumes,
    List<String> skillFilters = const [],
    String experienceFilter = '',
  }) async {
    // Convert RankedResume objects to Map for API call
    final resumeMaps = resumes.map((resume) => resume.toJson()).toList();

    final response = await http.post(
      _uri('/filter-resumes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'resumes': resumeMaps,
        'skill_filters': skillFilters,
        'experience_filter': experienceFilter,
      }),
    );
    return _decodeJson(response);
  }

  // RAG: store job description
  Future<Map<String, dynamic>> ragStoreJd({
    required String workspaceId,
    required String jobDescription,
  }) async {
    final response = await http.post(
      _uri('/rag/store-jd'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'workspace_id': workspaceId,
        'job_description': jobDescription,
      }),
    );
    if (response.statusCode != 200) {
      throw AtsException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // RAG: ingest
  Future<Map<String, dynamic>> ragIngest({
    required String workspaceId,
    required List<Map<String, dynamic>> resumes, // id, text, meta
  }) async {
    final response = await http.post(
      _uri('/rag/ingest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'workspace_id': workspaceId, 'resumes': resumes}),
    );
    return _decodeJson(response);
  }

  // RAG: suggest questions
  Future<Map<String, dynamic>> ragSuggest({
    required String workspaceId,
    required String resumeId,
  }) async {
    final response = await http.post(
      _uri('/rag/suggest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'workspace_id': workspaceId, 'resume_id': resumeId}),
    );
    return _decodeJson(response);
  }

  // RAG: query
  Future<Map<String, dynamic>> ragQuery({
    required String workspaceId,
    required String message,
    String? resumeId,
    String? chatId,
    int k = 5,
  }) async {
    final response = await http.post(
      _uri('/rag/query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'workspace_id': workspaceId,
        'message': message,
        if (resumeId != null) 'resume_id': resumeId,
        if (chatId != null) 'chat_id': chatId,
        'k': k,
      }),
    );
    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> analyzeResume({
    required String candidateName,
    required String email,
    required String phone,
    required String resumeText,
    required String jobDescription,
  }) async {
    // Mock implementation for now
    return {
      'success': true,
      'analysis': {
        'candidate_name': candidateName,
        'email': email,
        'phone': phone,
        'match_score': 75.5,
        'skills_match': ['JavaScript', 'Python', 'React'],
        'experience_level': 'Mid-level',
        'recommendations': [
          'Strong technical background',
          'Good communication skills',
          'Relevant experience in required technologies',
        ],
      },
    };
  }

  Future<Map<String, dynamic>> getAvailableSkills({
    required List<RankedResume> resumes,
  }) async {
    // Mock implementation for now
    return {
      'success': true,
      'availableSkills': [
        'JavaScript',
        'Python',
        'React',
        'Node.js',
        'Flutter',
        'Dart',
        'Java',
        'C++',
        'SQL',
        'MongoDB',
      ],
    };
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    final status = response.statusCode;
    final body = response.body.isEmpty ? '{}' : response.body;

    if (body.trim().startsWith('<!DOCTYPE') ||
        body.trim().startsWith('<html')) {
      throw AtsException(
        statusCode: status,
        message:
            'Backend unreachable: Received HTML response instead of JSON. Please check if the server is running.',
      );
    }

    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      if (status >= 200 && status < 300) {
        return decoded;
      }
      throw AtsException(
        statusCode: status,
        message: decoded['error']?.toString() ?? 'Request failed',
      );
    } catch (e) {
      if (e is FormatException) {
        throw AtsException(
          statusCode: status,
          message:
              'Backend unreachable: FormatException: ${e.message}. Response body: ${body.length > 100 ? body.substring(0, 100) + '...' : body}',
        );
      }
      rethrow;
    }
  }

  MediaType? _contentTypeFor(String? extension) {
    switch ((extension ?? '').toLowerCase()) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'docx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
      case 'doc':
        return MediaType('application', 'msword');
      default:
        return null;
    }
  }

  // Interview Scheduling Methods
  Future<bool> checkInterviewIntent(String message) async {
    try {
      final response = await http.post(
        _uri('/rag/check-interview-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['has_intent'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking interview intent: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> scheduleInterview({
    required String workspaceId,
    required String resumeId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        _uri('/rag/schedule-interview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'workspace_id': workspaceId,
          'resume_id': resumeId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to schedule interview: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error scheduling interview: $e'};
    }
  }

  Future<Map<String, dynamic>> getManualEmailData({
    required String workspaceId,
    required String resumeId,
    required Map<String, dynamic> interviewDetails,
  }) async {
    try {
      final response = await http.post(
        _uri('/rag/get-manual-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'workspace_id': workspaceId,
          'resume_id': resumeId,
          'interview_details': interviewDetails,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to get email data: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error getting email data: $e'};
    }
  }
}

class AtsException implements Exception {
  AtsException({required this.statusCode, required this.message});
  final int statusCode;
  final String message;
  @override
  String toString() => 'AtsException($statusCode): $message';
}
