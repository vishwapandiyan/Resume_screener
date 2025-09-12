import 'package:equatable/equatable.dart';

/// Model for a processed resume from the ATS system
class ProcessedResume extends Equatable {
  final String id;
  final String filename;
  final int atsScore;
  final String status; // accepted/rejected
  final List<String> skills;
  final String experience;
  final String email;
  final String textPreview;
  final String reason;
  final String? fullText; // For semantic ranking

  const ProcessedResume({
    required this.id,
    required this.filename,
    required this.atsScore,
    required this.status,
    required this.skills,
    required this.experience,
    required this.email,
    required this.textPreview,
    required this.reason,
    this.fullText,
  });

  factory ProcessedResume.fromJson(Map<String, dynamic> json) {
    return ProcessedResume(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      atsScore: json['ats_score'] ?? 0,
      status: json['status'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      experience: json['experience'] ?? '',
      email: json['email'] ?? '',
      textPreview: json['text_preview'] ?? '',
      reason: json['reason'] ?? '',
      fullText: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'ats_score': atsScore,
      'status': status,
      'skills': skills,
      'experience': experience,
      'email': email,
      'text_preview': textPreview,
      'reason': reason,
      if (fullText != null) 'text': fullText,
    };
  }

  ProcessedResume copyWith({
    String? id,
    String? filename,
    int? atsScore,
    String? status,
    List<String>? skills,
    String? experience,
    String? email,
    String? textPreview,
    String? reason,
    String? fullText,
  }) {
    return ProcessedResume(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      atsScore: atsScore ?? this.atsScore,
      status: status ?? this.status,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      email: email ?? this.email,
      textPreview: textPreview ?? this.textPreview,
      reason: reason ?? this.reason,
      fullText: fullText ?? this.fullText,
    );
  }

  @override
  List<Object?> get props => [
    id,
    filename,
    atsScore,
    status,
    skills,
    experience,
    email,
    textPreview,
    reason,
    fullText,
  ];
}

/// Model for ATS processing results
class ATSProcessingResult extends Equatable {
  final bool success;
  final int totalProcessed;
  final int acceptedCount;
  final int rejectedCount;
  final List<ProcessedResume> resumes;
  final ModelInfo modelInfo;
  final String? workflowId; // Generated on client side

  const ATSProcessingResult({
    required this.success,
    required this.totalProcessed,
    required this.acceptedCount,
    required this.rejectedCount,
    required this.resumes,
    required this.modelInfo,
    this.workflowId,
  });

  factory ATSProcessingResult.fromJson(Map<String, dynamic> json) {
    return ATSProcessingResult(
      success: json['success'] ?? false,
      totalProcessed: json['total_processed'] ?? 0,
      acceptedCount: json['accepted_count'] ?? 0,
      rejectedCount: json['rejected_count'] ?? 0,
      resumes:
          (json['resumes'] as List<dynamic>?)
              ?.map((item) => ProcessedResume.fromJson(item))
              .toList() ??
          [],
      modelInfo: ModelInfo.fromJson(json['model_info'] ?? {}),
    );
  }

  ATSProcessingResult copyWith({
    bool? success,
    int? totalProcessed,
    int? acceptedCount,
    int? rejectedCount,
    List<ProcessedResume>? resumes,
    ModelInfo? modelInfo,
    String? workflowId,
  }) {
    return ATSProcessingResult(
      success: success ?? this.success,
      totalProcessed: totalProcessed ?? this.totalProcessed,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      resumes: resumes ?? this.resumes,
      modelInfo: modelInfo ?? this.modelInfo,
      workflowId: workflowId ?? this.workflowId,
    );
  }

  @override
  List<Object?> get props => [
    success,
    totalProcessed,
    acceptedCount,
    rejectedCount,
    resumes,
    modelInfo,
    workflowId,
  ];
}

/// Model for ML model information
class ModelInfo extends Equatable {
  final double accuracy;
  final int totalSamples;

  const ModelInfo({required this.accuracy, required this.totalSamples});

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      totalSamples: json['total_samples'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'accuracy': accuracy, 'total_samples': totalSamples};
  }

  @override
  List<Object> get props => [accuracy, totalSamples];
}

/// Model for job description and its metadata
class JobDescription extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final String experienceLevel;
  final DateTime createdAt;

  const JobDescription({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.experienceLevel,
    required this.createdAt,
  });

  factory JobDescription.fromJson(Map<String, dynamic> json) {
    return JobDescription(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      experienceLevel: json['experience_level'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'required_skills': requiredSkills,
      'experience_level': experienceLevel,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [
    id,
    title,
    description,
    requiredSkills,
    experienceLevel,
    createdAt,
  ];
}

/// Model for ranked resume after semantic analysis
class RankedResume extends Equatable {
  final String id;
  final int rank;
  final String candidate;
  final int atsScore;
  final double semanticScore;
  final String matchStatus;
  final List<String> skills;
  final String experience;
  final String email;
  final List<String> foundSkills;

  const RankedResume({
    required this.id,
    required this.rank,
    required this.candidate,
    required this.atsScore,
    required this.semanticScore,
    required this.matchStatus,
    required this.skills,
    required this.experience,
    required this.email,
    required this.foundSkills,
  });

  factory RankedResume.fromJson(Map<String, dynamic> json) {
    return RankedResume(
      id: json['id'] ?? '',
      rank: json['rank'] ?? 0,
      candidate: json['candidate'] ?? '',
      atsScore: json['ats_score'] ?? 0,
      semanticScore: (json['semantic_score'] ?? 0.0).toDouble(),
      matchStatus: json['match_status'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      experience: json['experience'] ?? '',
      email: json['email'] ?? '',
      foundSkills: List<String>.from(json['found_skills'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rank': rank,
      'candidate': candidate,
      'ats_score': atsScore,
      'semantic_score': semanticScore,
      'match_status': matchStatus,
      'skills': skills,
      'experience': experience,
      'email': email,
      'found_skills': foundSkills,
    };
  }

  @override
  List<Object> get props => [
    id,
    rank,
    candidate,
    atsScore,
    semanticScore,
    matchStatus,
    skills,
    experience,
    email,
    foundSkills,
  ];
}

/// Model for semantic ranking results
class SemanticRankingResult extends Equatable {
  final bool success;
  final bool jobDescriptionStored;
  final List<RankedResume> rankedResumes;
  final RankingSummary summary;
  final List<String> jdSkills;

  const SemanticRankingResult({
    required this.success,
    required this.jobDescriptionStored,
    required this.rankedResumes,
    required this.summary,
    this.jdSkills = const [],
  });

  factory SemanticRankingResult.fromJson(Map<String, dynamic> json) {
    return SemanticRankingResult(
      success: json['success'] ?? false,
      jobDescriptionStored: json['job_description_stored'] ?? false,
      rankedResumes:
          (json['ranked_resumes'] as List<dynamic>?)
              ?.map((item) => RankedResume.fromJson(item))
              .toList() ??
          [],
      summary: RankingSummary.fromJson(json['summary'] ?? {}),
      jdSkills: List<String>.from(json['jd_skills'] ?? const <String>[]),
    );
  }

  @override
  List<Object> get props => [
    success,
    jobDescriptionStored,
    rankedResumes,
    summary,
    jdSkills,
  ];
}

/// Model for ranking summary statistics
class RankingSummary extends Equatable {
  final int totalCandidates;
  final int excellentMatches;
  final int goodMatches;
  final double avgSemanticScore;

  const RankingSummary({
    required this.totalCandidates,
    required this.excellentMatches,
    required this.goodMatches,
    required this.avgSemanticScore,
  });

  factory RankingSummary.fromJson(Map<String, dynamic> json) {
    return RankingSummary(
      totalCandidates: json['total_candidates'] ?? 0,
      excellentMatches: json['excellent_matches'] ?? 0,
      goodMatches: json['good_matches'] ?? 0,
      avgSemanticScore: (json['avg_semantic_score'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object> get props => [
    totalCandidates,
    excellentMatches,
    goodMatches,
    avgSemanticScore,
  ];
}

/// Model for filtering results
class FilterResult extends Equatable {
  final bool success;
  final List<RankedResume> filteredResumes;
  final FilterSummary filterSummary;

  const FilterResult({
    required this.success,
    required this.filteredResumes,
    required this.filterSummary,
  });

  factory FilterResult.fromJson(Map<String, dynamic> json) {
    return FilterResult(
      success: json['success'] ?? false,
      filteredResumes:
          (json['filtered_resumes'] as List<dynamic>?)
              ?.map((item) => RankedResume.fromJson(item))
              .toList() ??
          [],
      filterSummary: FilterSummary.fromJson(json['filter_summary'] ?? {}),
    );
  }

  @override
  List<Object> get props => [success, filteredResumes, filterSummary];
}

/// Model for filter summary
class FilterSummary extends Equatable {
  final int totalInput;
  final int filteredOutput;
  final FilterCriteria filterCriteria;

  const FilterSummary({
    required this.totalInput,
    required this.filteredOutput,
    required this.filterCriteria,
  });

  factory FilterSummary.fromJson(Map<String, dynamic> json) {
    return FilterSummary(
      totalInput: json['total_input'] ?? 0,
      filteredOutput: json['filtered_output'] ?? 0,
      filterCriteria: FilterCriteria.fromJson(json['filter_criteria'] ?? {}),
    );
  }

  @override
  List<Object> get props => [totalInput, filteredOutput, filterCriteria];
}

/// Model for filter criteria
class FilterCriteria extends Equatable {
  final List<String> skills;
  final String experience;

  const FilterCriteria({required this.skills, required this.experience});

  factory FilterCriteria.fromJson(Map<String, dynamic> json) {
    return FilterCriteria(
      skills: List<String>.from(json['skills'] ?? []),
      experience: json['experience'] ?? '',
    );
  }

  @override
  List<Object> get props => [skills, experience];
}

/// Model for available skills response
class AvailableSkillsResult extends Equatable {
  final bool success;
  final List<String> availableSkills;
  final int skillCount;

  const AvailableSkillsResult({
    required this.success,
    required this.availableSkills,
    required this.skillCount,
  });

  factory AvailableSkillsResult.fromJson(Map<String, dynamic> json) {
    return AvailableSkillsResult(
      success: json['success'] ?? false,
      availableSkills: List<String>.from(json['available_skills'] ?? []),
      skillCount: json['skill_count'] ?? 0,
    );
  }

  @override
  List<Object> get props => [success, availableSkills, skillCount];
}

/// Model for workflow state management
class ATSWorkflowState extends Equatable {
  final String? workflowId;
  final String? jobId;
  final ATSProcessingResult? processingResult;
  final JobDescription? jobDescription;
  final SemanticRankingResult? rankingResult;
  final List<String>? availableSkills;
  final FilterResult? filterResult;
  final int currentStep;

  const ATSWorkflowState({
    this.workflowId,
    this.jobId,
    this.processingResult,
    this.jobDescription,
    this.rankingResult,
    this.availableSkills,
    this.filterResult,
    this.currentStep = 0,
  });

  ATSWorkflowState copyWith({
    String? workflowId,
    String? jobId,
    ATSProcessingResult? processingResult,
    JobDescription? jobDescription,
    SemanticRankingResult? rankingResult,
    List<String>? availableSkills,
    FilterResult? filterResult,
    int? currentStep,
  }) {
    return ATSWorkflowState(
      workflowId: workflowId ?? this.workflowId,
      jobId: jobId ?? this.jobId,
      processingResult: processingResult ?? this.processingResult,
      jobDescription: jobDescription ?? this.jobDescription,
      rankingResult: rankingResult ?? this.rankingResult,
      availableSkills: availableSkills ?? this.availableSkills,
      filterResult: filterResult ?? this.filterResult,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  @override
  List<Object?> get props => [
    workflowId,
    jobId,
    processingResult,
    jobDescription,
    rankingResult,
    availableSkills,
    filterResult,
    currentStep,
  ];
}
