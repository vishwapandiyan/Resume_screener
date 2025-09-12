class ProcessResultSummary {
  ProcessResultSummary({
    required this.success,
    required this.totalProcessed,
    required this.acceptedCount,
    required this.rejectedCount,
    required this.resumes,
  });

  final bool success;
  final int totalProcessed;
  final int acceptedCount;
  final int rejectedCount;
  final List<ProcessedResume> resumes;

  factory ProcessResultSummary.fromJson(Map<String, dynamic> json) {
    final resumesJson = (json['resumes'] as List<dynamic>? ?? []);
    return ProcessResultSummary(
      success: json['success'] == true,
      totalProcessed: json['total_processed'] is int
          ? json['total_processed'] as int
          : 0,
      acceptedCount: json['accepted_count'] is int
          ? json['accepted_count'] as int
          : 0,
      rejectedCount: json['rejected_count'] is int
          ? json['rejected_count'] as int
          : 0,
      resumes: resumesJson
          .map((e) => ProcessedResume.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProcessedResume {
  ProcessedResume({
    required this.id,
    required this.filename,
    required this.atsScore,
    required this.status,
    required this.skills,
    required this.experience,
    required this.email,
    required this.textPreview,
    required this.reason,
  });

  final String id;
  final String filename;
  final int atsScore;
  final String status;
  final List<String> skills;
  final String experience;
  final String email;
  final String textPreview;
  final String reason;

  factory ProcessedResume.fromJson(Map<String, dynamic> json) {
    return ProcessedResume(
      id: json['id']?.toString() ?? '',
      filename: json['filename']?.toString() ?? '',
      atsScore: json['ats_score'] is int ? json['ats_score'] as int : 0,
      status: json['status']?.toString() ?? '',
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      experience: json['experience']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      textPreview: json['text_preview']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJsonForRanking() {
    return {
      'id': id,
      'filename': filename,
      'text': textPreview,
      'ats_score': atsScore,
      'skills': skills,
      'experience': experience,
      'email': email,
    };
  }
}

class AtsConfig {
  static const String baseUrl = String.fromEnvironment(
    'ATS_BASE_URL',
    defaultValue: 'https://8ce23fc7ce28.ngrok-free.app',
  );
}

